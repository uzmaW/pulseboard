defmodule PulseboardCore.RealtimeSessionTest do
  use ExUnit.Case

  alias PulseboardCore.RealtimeSession

  describe "new/1" do
    test "creates a new session with valid attributes" do
      attrs = %{
        tenant_id: "tenant-1",
        participants: [%{user_id: "user-1", role: :host}],
        context: :support_ticket,
        mode: :call
      }

      assert {:ok, %RealtimeSession{} = session} = RealtimeSession.new(attrs)
      assert session.tenant_id == "tenant-1"
      assert session.context == :support_ticket
      assert session.mode == :call
      assert session.status == :pending
    end

    test "returns error for invalid mode" do
      attrs = %{
        tenant_id: "tenant-1",
        mode: :invalid
      }

      assert {:error, :invalid_mode} = RealtimeSession.new(attrs)
    end

    test "returns error for invalid context" do
      attrs = %{
        tenant_id: "tenant-1",
        context: :invalid,
        mode: :call
      }

      assert {:error, :invalid_context} = RealtimeSession.new(attrs)
    end
  end

  describe "start/1" do
    test "starts the session" do
      {:ok, session} = RealtimeSession.new(%{
        tenant_id: "tenant-1",
        context: :general,
        mode: :call
      })

      started = RealtimeSession.start(session)
      assert started.status == :active
      assert started.started_at != nil
    end
  end

  describe "end_session/1" do
    test "ends the session" do
      {:ok, session} = RealtimeSession.new(%{
        tenant_id: "tenant-1",
        context: :general,
        mode: :call
      })

      started = RealtimeSession.start(session)
      ended = RealtimeSession.end_session(started)
      assert ended.status == :completed
      assert ended.ended_at != nil
    end
  end

  describe "add_participant/3" do
    test "adds a participant to the session" do
      {:ok, session} = RealtimeSession.new(%{
        tenant_id: "tenant-1",
        context: :general,
        mode: :call
      })

      updated = RealtimeSession.add_participant(session, "user-1", :host)
      assert length(updated.participants) == 1
      assert hd(updated.participants).user_id == "user-1"
      assert hd(updated.participants).role == :host
    end
  end

  describe "remove_participant/2" do
    test "removes a participant from the session" do
      {:ok, session} = RealtimeSession.new(%{
        tenant_id: "tenant-1",
        context: :general,
        mode: :call
      })

      session = RealtimeSession.add_participant(session, "user-1", :host)
      updated = RealtimeSession.remove_participant(session, "user-1")
      assert hd(updated.participants).left_at != nil
    end
  end

  describe "participant_count/1" do
    test "counts active participants" do
      {:ok, session} = RealtimeSession.new(%{
        tenant_id: "tenant-1",
        context: :general,
        mode: :call
      })

      session = RealtimeSession.add_participant(session, "user-1", :host)
      session = RealtimeSession.add_participant(session, "user-2", :guest)
      session = RealtimeSession.remove_participant(session, "user-1")

      assert RealtimeSession.participant_count(session) == 1
    end
  end
end
