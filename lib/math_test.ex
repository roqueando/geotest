defmodule MathTest do
  def earth_radius, do: 6378137
  def haversine(x) do
    sin_half = :math.sin(x * 0.5)
    sin_half * sin_half
  end

  def deg2rad(degrees) do
    degrees * :math.pi() / 180
  end

  def haversine_distance(lat1, lat2, dlng) do
    haversine(lat1 - lat2) + haversine(dlng) * :math.cos(lat1) * :math.cos(lat2)
  end

  def sin_from_haversine(haversine) do
    2 * :math.sqrt(haversine * (1 - haversine))
  end

  def hav_from_sin(x) do
    x2 = x * x
    x2 / (1 + :math.sqrt(1 - x2)) * 0.5;
  end

  def sin_sum_from_hav(x, y) do
    a = :math.sqrt(x * (1 - x))
    b = :math.sqrt(y * (1 - y))

    2 * (a + b - 2 * (a * y + b * x));
  end
end
