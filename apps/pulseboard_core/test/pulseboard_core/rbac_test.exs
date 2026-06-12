defmodule PulseboardCore.RBACTest do
  use ExUnit.Case

  alias PulseboardCore.RBAC

  describe "create_role/3" do
    test "creates a new role" do
      assert {:ok, role} = RBAC.create_role("tenant-1", "Admin", ["*"])
      assert role.tenant_id == "tenant-1"
      assert role.name == "Admin"
      assert role.permissions == ["*"]
    end

    test "creates a role with default permissions" do
      assert {:ok, role} = RBAC.create_role("tenant-1", "Member")
      assert role.permissions == []
    end
  end

  describe "assign_role/3" do
    test "assigns a role to a user" do
      assert {:ok, assignment} = RBAC.assign_role("user-1", "role-1", "tenant-1")
      assert assignment.user_id == "user-1"
      assert assignment.role_id == "role-1"
      assert assignment.tenant_id == "tenant-1"
    end
  end

  describe "allowed?/4" do
    test "returns true when user has required role" do
      roles = [%{name: "Admin", tenant_id: "tenant-1", permissions: ["*"]}]
      assert RBAC.allowed?("user-1", "tenant-1", ["Admin"], roles)
    end

    test "returns false when user doesn't have required role" do
      roles = [%{name: "Member", tenant_id: "tenant-1", permissions: ["read"]}]
      refute RBAC.allowed?("user-1", "tenant-1", ["Admin"], roles)
    end
  end

  describe "has_permission?/2" do
    test "returns true when role has permission" do
      roles = [%PulseboardCore.RBAC.Role{id: "1", tenant_id: "t1", name: "Admin", permissions: ["*"], created_at: DateTime.utc_now()}]
      assert RBAC.has_permission?("users:read", roles)
    end

    test "returns false when role doesn't have permission" do
      roles = [%PulseboardCore.RBAC.Role{id: "1", tenant_id: "t1", name: "Member", permissions: ["read"], created_at: DateTime.utc_now()}]
      refute RBAC.has_permission?("users:delete", roles)
    end
  end

  describe "default_roles/0" do
    test "returns default roles" do
      roles = RBAC.default_roles()
      assert length(roles) == 3
      assert Enum.any?(roles, &(&1.name == "Admin"))
      assert Enum.any?(roles, &(&1.name == "Member"))
      assert Enum.any?(roles, &(&1.name == "Guest"))
    end
  end
end
