defmodule GeoTestTest do
  use ExUnit.Case

  test "check is location edge" do
    point = {-3.729696, -38.479859}
    polylines = [
      %{lat: -2.971547, lng: -47.605833},
      %{lat: -2.9784, lng: -47.528292},
      %{lat: -2.972732, lng: -47.59337}
    ]
    GeoTest.is_location_on_edge(point, polylines)
    |> IO.inspect()
  end
end
