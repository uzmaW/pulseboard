defmodule PulseboardImpersonationTest do
  use ExUnit.Case

  test "start/1 returns ok with session" do
    attrs = %{
      tenant_id: "tenant-1",
      admin_id: "admin-1",
      target_user_id: "user-1",
      reason: "Support request"
    }

    assert {:ok, session} = PulseboardImpersonation.start(attrs)
    assert session.admin_id == "admin-1"
    assert session.target_user_id == "user-1"
  end

  test "end_session/1 returns ended session" do
    {:ok, session} = PulseboardImpersonation.start(%{
      tenant_id: "tenant-1",
      admin_id: "admin-1",
      target_user_id: "user-1",
      reason: "Support request"
    })

    ended = PulseboardImpersonation.end_session(session)
    assert ended.status == :completed
  end

  test "impersonating?/1 returns true for active session" do
    {:ok, session} = PulseboardImpersonation.start(%{
      tenant_id: "tenant-1",
      admin_id: "admin-1",
      target_user_id: "user-1",
      reason: "Support request"
    })

    assert PulseboardImpersonation.impersonating?(session)
  end
end
