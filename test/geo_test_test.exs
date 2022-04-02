defmodule GeoTestTest do
  use ExUnit.Case

  test "check is location edge" do
    point = {-3.729848779895589, -38.47981178519322}
    polylines = [
      %{lat: -3.7302098905400407, lng: -38.48138249802991},
      %{lat: -3.7618779814726495, lng: -38.50804365559882},
      %{lat: -3.780758350234388, lng: -38.54586513382312}
    ]
    assert GeoTest.is_location_on_edge(point, polylines) == true
  end

  test "check is location not in edge" do
    point = {-35.680229523085, 156.394660206120}
    polylines = [
      %{lat: -3.7302098905400407, lng: -38.48138249802991},
      %{lat: -3.7618779814726495, lng: -38.50804365559882},
      %{lat: -3.780758350234388, lng: -38.54586513382312}
    ]
    assert GeoTest.is_location_on_edge(point, polylines) == false
  end

  test "check is location on edge by two points" do
    point_one = {-3.729848779895589, -38.47981178519322}
    point_two = {-3.7297524422763018, -38.48107780603302}

    polylines = [
      %{lat: -3.7302098905400407, lng: -38.48138249802991},
      %{lat: -3.7618779814726495, lng: -38.50804365559882},
      %{lat: -3.780758350234388, lng: -38.54586513382312}
    ]
    point_one_is_on_location = GeoTest.is_location_on_edge(point_one, polylines)
    point_two_is_on_location = GeoTest.is_location_on_edge(point_two, polylines)

    assert point_one_is_on_location == true
    assert point_two_is_on_location == true
  end
end
