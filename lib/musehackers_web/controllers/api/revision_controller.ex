defmodule MusehackersWeb.Api.RevisionController do
  use MusehackersWeb, :controller

  alias Musehackers.VersionControl
  alias Musehackers.VersionControl.Revision

  action_fallback MusehackersWeb.Api.FallbackController

  def show(%{assigns: %{version: :v1}} = conn, %{"id" => id}) do
    revision = VersionControl.get_revision!(id)
    conn
    |> put_status(:ok)
    |> render("show.v1.json", revision: revision)
  end

  def create(%{assigns: %{version: :v1}} = conn, %{"id" => id, "revision" => revision_params}) do
    with attrs <- Map.put(revision_params, "id", id),
        {:ok, %Revision{} = _} <- VersionControl.create_revision(attrs) do
      conn
      |> send_resp(:created, "")
      |> halt()
    end
  end
end
