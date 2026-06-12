defmodule PulseboardWeb.Input do
  @moduledoc """
  Simple input component for forms.
  """

  use Phoenix.Component

  attr :field, Phoenix.HTML.FormField, required: true
  attr :type, :string, default: "text"
  attr :placeholder, :string, default: ""

  def input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns =
      assigns
      |> assign(:id, field.id)
      |> assign(:name, field.name)
      |> assign(:value, field.value)
      |> assign(:errors, field.errors)

    ~H"""
    <input
      type={@type}
      name={@name}
      id={@id}
      value={@value}
      placeholder={@placeholder}
      class="form-input"
      aria-invalid={if @errors != [], do: "true"}
      aria-describedby={if @errors != [], do: "#{@id}-error"}
    />
    <p :if={@errors != []} id={"#{@id}-error"} class="form-error">
      {inspect(List.first(@errors))}
    </p>
    """
  end
end
