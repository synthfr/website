defmodule MusehackersWeb.Api.ProjectController do
  use MusehackersWeb, :controller

  alias Musehackers.VersionControl
  alias Musehackers.VersionControl.Project

  action_fallback MusehackersWeb.Api.FallbackController

  def summary(%{assigns: %{version: :v1}} = conn, %{"id" => id}) do
    project = VersionControl.get_project!(id)
    conn |> put_status(:ok) |> render("show.v1.json", project: project)
  end

  def heads(%{assigns: %{version: :v1}} = conn, %{"id" => id}) do
    with {:ok, heads} <- VersionControl.get_project_heads(id) do
      conn
      |> put_status(:ok)
      |> render("show.heads.v1.json", heads: heads)
    end
  end

  plug Guardian.Plug.LoadResource, ensure: true

  def create_or_update(%{assigns: %{version: :v1}} = conn, %{"id" => id, "project" => project_params}) do
    project_params = Map.put(project_params, "id", id)
    with user <- Guardian.Plug.current_resource(conn),
        attrs <- Map.put(project_params, "author_id", user.id),
        {:ok, %Project{} = project} <- VersionControl.create_or_update_project(attrs) do
      conn
      |> put_status(:ok)
      |> render("show.v1.json", project: project)
    end
  end
end
