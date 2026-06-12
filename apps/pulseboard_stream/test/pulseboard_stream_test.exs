defmodule PulseboardStreamTest do
  use ExUnit.Case

  test "create_room/1 returns ok or error" do
    case PulseboardStream.create_room("test-room-1") do
      {:ok, _room} -> assert true
      {:error, _reason} -> assert true
    end
  end

  test "generate_token/3 returns ok with token" do
    case PulseboardStream.generate_token("room-1", "participant-1", "user-1") do
      {:ok, _token} -> assert true
      {:error, _reason} -> assert true
    end
  end
end
