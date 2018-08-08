defmodule DoppelkopfWeb.Router do
  use DoppelkopfWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/api", DoppelkopfWeb do
    pipe_through(:api)
  end
end
