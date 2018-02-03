defmodule MusehackersWeb.Api.V1.RegistrationController do
  use MusehackersWeb, :controller
  @moduledoc false

  alias Musehackers.Accounts
  alias Musehackers.Accounts.User

  action_fallback MusehackersWeb.Api.V1.FallbackController

  def sign_up(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Accounts.register_user(user_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", api_v1_user_path(conn, :show, user))
      |> render("success.json", user: user)
    end
  end
end