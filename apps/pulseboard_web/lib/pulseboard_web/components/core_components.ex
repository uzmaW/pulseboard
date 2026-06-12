defmodule PulseboardWeb.CoreComponents do
  @moduledoc """
  Core UI components for PulseBoard.
  """

  use Phoenix.Component

  @doc """
  Flash messages component.
  """
  attr :flash, :map, required: true

  def flash_group(assigns) do
    ~H"""
    <div id="flash-group">
      <p :if={Phoenix.Flash.get(@flash, :info)} class="flash flash-info">
        {Phoenix.Flash.get(@flash, :info)}
      </p>
      <p :if={Phoenix.Flash.get(@flash, :error)} class="flash flash-error">
        {Phoenix.Flash.get(@flash, :error)}
      </p>
    </div>
    """
  end

  @doc """
  Simple button component.
  """
  slot :inner_block, required: true
  attr :class, :string, default: ""
  attr :rest, :global

  def button(assigns) do
    ~H"""
    <button class={["btn", @class]} {@rest}>
      {render_slot(@inner_block)}
    </button>
    """
  end

  @doc """
  Card component.
  """
  slot :inner_block, required: true
  attr :title, :string, default: nil
  attr :class, :string, default: ""

  def card(assigns) do
    ~H"""
    <div class={["card", @class]}>
      <div :if={@title} class="card-header">
        <h3>{@title}</h3>
      </div>
      <div class="card-body">
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  @doc """
  Badge component for status display.
  """
  slot :inner_block, required: true
  attr :variant, :string, default: "default"
  attr :class, :string, default: ""

  def badge(assigns) do
    ~H"""
    <span class={["badge", "badge-#{@variant}", @class]}>
      {render_slot(@inner_block)}
    </span>
    """
  end
end
