defmodule GeoTest do
  @default_tolerance 0.1

  @doc """
    That function will calculate if that point is off the route
    point is a tuple like {123999.98, -33.9330383} as latitude longitude
    polyline is a list of latitude and longitude as [{..., ...}, {..., ...}]
    tolerance will be the fault in meters
  """
  def is_location_on_edge(point, polylines, tolerance \\ @default_tolerance, geodesic \\ true) do
    is_location_on_edge_or_path(point, polylines, true, geodesic, tolerance)
  end

  defp is_location_on_edge_or_path(_point, [] = _polylines, _closed, _geodesic, _toleranceEarth), do: false
  defp is_location_on_edge_or_path({lat, lng} = _point, polylines, closed, geodesic, toleranceEarth) do
    size = length(polylines)

    tolerance = toleranceEarth / MathTest.earth_radius()
    haversine_tolerance = MathTest.haversine(tolerance)

    lat3 = Math.deg2rad(lat)
    lng3 = Math.deg2rad(lng)
    prev = if !closed, do: Enum.at(polylines, size - 1), else: Enum.at(polylines, 0)
    lat1 = Math.deg2rad(prev.lat)
    lng1 = Math.deg2rad(prev.lng)

    if geodesic do
      Enum.reduce(polylines, %{lat: lat1, lng: lng1}, fn %{lat: lat, lng: lng}, acc ->
        lat2 = MathTest.deg2rad(lat)
        lng2 = MathTest.deg2rad(lng)
        if is_on_segment_gc(acc.lat, acc.lng, lat2, lng2, lat3, lng3, haversine_tolerance) do
          true
        else 
          Map.merge(acc, %{lat: lat2, lng: lng2})
        end
      end)
      |> Enum.member?(true)
    end
  end

  defp is_on_segment_gc(lat1, lng1, lat2, lng2, lat3, lng3, haversine_tolerance) do
    hav_distance13 = MathTest.haversine_distance(lat1, lat3, lng1 - lng3)
    hav_distance23 = MathTest.haversine_distance(lat2, lat3, lng2 - lng3)

    sin_bearing = sin_delta_bearing(lat1, lng1, lat2, lng2, lat3, lng3)
    sin_dist13 = MathTest.sin_from_haversine(hav_distance13)
    hav_cross_track = MathTest.hav_from_sin(sin_dist13 * sin_bearing)

    hav_distance12 = MathTest.haversine_distance(lat1, lat2, lng1 - lng2)
    term = hav_distance12 + hav_cross_track * (1 - 2 * hav_distance12)

    cos_cross_track = 1 - 2 * hav_cross_track
    hav_along_track13 = (hav_distance13 - hav_cross_track) / cos_cross_track
    hav_along_track23 = (hav_distance23 - hav_cross_track) / cos_cross_track

    cond do
      hav_distance13 <= haversine_tolerance -> true
      hav_distance23 <= haversine_tolerance -> true
      hav_cross_track > haversine_tolerance -> false
      hav_distance13 > term || hav_distance23 > term -> false
      hav_distance12 < 0.74 -> true
      true ->
        sin_sum_along_track = MathTest.sin_sum_from_hav(hav_along_track13, hav_along_track23)
        sin_sum_along_track > 0
    end
  end

  defp sin_delta_bearing(lat1, lng1, lat2, lng2, lat3, lng3) do
    sin_lat1 = :math.sin(lat1)
    cos_lat2 = :math.cos(lat2)
    cos_lat3 = :math.cos(lat3)

    lat31 = lat3 - lat1
    lng31 = lng3 - lng1
    lat21 = lat2 - lat1
    lng21 = lng2 - lng1

    a = :math.sin(lng31) * cos_lat3
    c = :math.sin(lng21) * cos_lat2;
    b = :math.sin(lat31) + 2 * sin_lat1 * cos_lat2 * MathTest.haversine(lng31)
    d = :math.sin(lat21) + 2 * sin_lat1 * cos_lat2 * MathTest.haversine(lng21)

    denom = (a * a + b * b) * (c * c + d * d)
    if denom <= 0, do: 1, else: (a * d - b * c) / :math.sqrt(denom)
  end
end
