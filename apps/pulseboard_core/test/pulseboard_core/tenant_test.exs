defmodule PulseboardCore.TenantTest do
  use ExUnit.Case

  alias PulseboardCore.Tenant

  describe "new/1" do
    test "creates a new tenant with valid attributes" do
      attrs = %{
        name: "Acme Corp",
        region: :us,
        domain: "acme.io",
        admin_user_id: "user-1"
      }

      assert {:ok, %Tenant{} = tenant} = Tenant.new(attrs)
      assert tenant.name == "Acme Corp"
      assert tenant.region == :us
      assert tenant.domain == "acme.io"
      assert tenant.admin_user_id == "user-1"
      assert tenant.status == :pending
    end

    test "returns error for invalid region" do
      attrs = %{
        name: "Acme Corp",
        region: :invalid,
        domain: "acme.io",
        admin_user_id: "user-1"
      }

      assert {:error, :invalid_region} = Tenant.new(attrs)
    end

    test "generates id when not provided" do
      attrs = %{
        name: "Acme Corp",
        region: :us,
        domain: "acme.io",
        admin_user_id: "user-1"
      }

      assert {:ok, %Tenant{id: id}} = Tenant.new(attrs)
      assert is_binary(id)
    end
  end

  describe "activate/1" do
    test "activates a tenant" do
      {:ok, tenant} = Tenant.new(%{
        name: "Acme Corp",
        region: :us,
        domain: "acme.io",
        admin_user_id: "user-1"
      })

      activated = Tenant.activate(tenant)
      assert activated.status == :active
    end
  end

  describe "suspend/1" do
    test "suspends a tenant" do
      {:ok, tenant} = Tenant.new(%{
        name: "Acme Corp",
        region: :us,
        domain: "acme.io",
        admin_user_id: "user-1"
      })

      suspended = Tenant.suspend(tenant)
      assert suspended.status == :suspended
    end
  end

  describe "active?/1" do
    test "returns true for active tenant" do
      {:ok, tenant} = Tenant.new(%{
        name: "Acme Corp",
        region: :us,
        domain: "acme.io",
        admin_user_id: "user-1"
      })

      assert Tenant.active?(Tenant.activate(tenant))
    end

    test "returns false for pending tenant" do
      {:ok, tenant} = Tenant.new(%{
        name: "Acme Corp",
        region: :us,
        domain: "acme.io",
        admin_user_id: "user-1"
      })

      refute Tenant.active?(tenant)
    end
  end
end
