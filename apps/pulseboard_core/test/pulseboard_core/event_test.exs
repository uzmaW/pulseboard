defmodule PulseboardCore.EventTest do
  use ExUnit.Case

  alias PulseboardCore.Event

  describe "new/4" do
    test "creates a new event with required fields" do
      event = Event.new(:tenant_onboarded, "tenant-1", "user-1", %{name: "Acme"})
      assert event.type == :tenant_onboarded
      assert event.tenant_id == "tenant-1"
      assert event.user_id == "user-1"
      assert event.payload == %{name: "Acme"}
    end

    test "creates event with default payload" do
      event = Event.new(:test_event, "tenant-1")
      assert event.payload == %{}
    end

    test "generates a unique id" do
      event1 = Event.new(:test, "tenant-1")
      event2 = Event.new(:test, "tenant-1")
      assert event1.id != event2.id
    end

    test "sets timestamp" do
      event = Event.new(:test, "tenant-1")
      assert %DateTime{} = event.timestamp
    end
  end
end
