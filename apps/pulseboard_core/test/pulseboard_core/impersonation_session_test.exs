defmodule PulseboardCore.ImpersonationSessionTest do
  use ExUnit.Case

  alias PulseboardCore.ImpersonationSession

  describe "new/1" do
    test "creates a new impersonation session" do
      attrs = %{
        tenant_id: "tenant-1",
        admin_id: "admin-1",
        target_user_id: "user-1",
        reason: "Support request",
        scope: :support
      }

      assert {:ok, %ImpersonationSession{} = session} = ImpersonationSession.new(attrs)
      assert session.tenant_id == "tenant-1"
      assert session.admin_id == "admin-1"
      assert session.target_user_id == "user-1"
      assert session.reason == "Support request"
      assert session.scope == :support
      assert session.status == :active
    end
  end

  describe "end_session/1" do
    test "ends the impersonation session" do
      {:ok, session} = ImpersonationSession.new(%{
        tenant_id: "tenant-1",
        admin_id: "admin-1",
        target_user_id: "user-1",
        reason: "Support request"
      })

      ended = ImpersonationSession.end_session(session)
      assert ended.status == :completed
      assert ended.ended_at != nil
    end
  end

  describe "revoke/1" do
    test "revokes the impersonation session" do
      {:ok, session} = ImpersonationSession.new(%{
        tenant_id: "tenant-1",
        admin_id: "admin-1",
        target_user_id: "user-1",
        reason: "Support request"
      })

      revoked = ImpersonationSession.revoke(session)
      assert revoked.status == :revoked
    end
  end

  describe "log_action/3" do
    test "logs an action in the audit trail" do
      {:ok, session} = ImpersonationSession.new(%{
        tenant_id: "tenant-1",
        admin_id: "admin-1",
        target_user_id: "user-1",
        reason: "Support request"
      })

      logged = ImpersonationSession.log_action(session, "viewed_profile", "user-1")
      assert length(logged.audit_trail) == 1
      assert hd(logged.audit_trail).action == "viewed_profile"
    end
  end

  describe "action_allowed?/2" do
    test "allows non-restricted actions" do
      {:ok, session} = ImpersonationSession.new(%{
        tenant_id: "tenant-1",
        admin_id: "admin-1",
        target_user_id: "user-1",
        reason: "Support request"
      })

      assert ImpersonationSession.action_allowed?(session, "viewed_profile")
    end

    test "disallows restricted actions" do
      {:ok, session} = ImpersonationSession.new(%{
        tenant_id: "tenant-1",
        admin_id: "admin-1",
        target_user_id: "user-1",
        reason: "Support request"
      })

      refute ImpersonationSession.action_allowed?(session, "change_password")
      refute ImpersonationSession.action_allowed?(session, "update_billing")
    end
  end

  describe "active?/1" do
    test "returns true for active session" do
      {:ok, session} = ImpersonationSession.new(%{
        tenant_id: "tenant-1",
        admin_id: "admin-1",
        target_user_id: "user-1",
        reason: "Support request"
      })

      assert ImpersonationSession.active?(session)
    end

    test "returns false for ended session" do
      {:ok, session} = ImpersonationSession.new(%{
        tenant_id: "tenant-1",
        admin_id: "admin-1",
        target_user_id: "user-1",
        reason: "Support request"
      })

      refute ImpersonationSession.active?(ImpersonationSession.end_session(session))
    end
  end
end
