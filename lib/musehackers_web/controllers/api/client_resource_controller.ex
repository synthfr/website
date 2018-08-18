defmodule MusehackersWeb.Api.ClientResourceController do
  use MusehackersWeb, :controller
  @moduledoc false

  alias Musehackers.Clients
  alias Musehackers.Clients.Resource

  action_fallback MusehackersWeb.Api.FallbackController

  def get_client_resource(%{assigns: %{version: :v1}} = conn, %{"app" => app_name, "resource" => resource_name}) do
    with {:ok, %Resource{} = resource} <- Clients.get_resource_for_app(app_name, resource_name),
      do: render(conn, "resource.data.v1.json", resource: resource)
  end

  plug Guardian.Permissions.Bitwise, [ensure: %{admin: [:write]}] when action in [:update_client_resource]

  # for helio translations, force running a worker to fetch them
  def update_client_resource(%{assigns: %{version: :v1}} = conn, %{"app" => app_name, "resource" => resource_name})
  when app_name == "helio" and resource_name == "translations" do
    children = Supervisor.which_children(Musehackers.Jobs.Supervisor)
    worker_timeout = 1000 * 30
    pid = children
      |> Enum.filter(fn{name, _, _, _} -> name == Elixir.Musehackers.Jobs.Etl.Translations end)
      |> Enum.map(fn{_, pid, _, _} -> pid end)
      |> List.first
    with {:ok, %Resource{} = resource} <- GenServer.call(pid, :process, worker_timeout),
      do: render(conn, "resource.data.v1.json", resource: resource)
  end

  def update_client_resource(%{assigns: %{version: :v1}} = conn, _params),
    do: conn |> send_resp(:not_found, "") |> halt()

end
