defmodule LiveViewTodosWeb.TodoLive do
    use Phoenix.LiveView

    alias LiveViewTodos.Todos
    alias LiveViewTodosWeb.TodoView
  
    def mount(_session, socket) do
      Todos.subscribe()
      {:ok, fetch(socket)}
    end
  
    def render(assigns) do
      TodoView.render("todos.html", assigns)
    end

    def handle_event("add", %{"todo" => todo}, socket) do
      Todos.create_todo(todo)
      {:noreply, fetch(socket)}
    end

    def handle_event("update", %{"todo" => new_todo}, socket) do
      old_todo = Todos.get_todo!(Map.get(new_todo, "id"))
      Todos.update_todo(old_todo, new_todo)
      {:noreply, fetch(socket)}
    end

    def handle_event("edit_todo", val, socket) do
      {:noreply, update(socket, :edit_id, fn _ -> String.to_integer(val) end)}
    end

    def handle_event("toggle_done", id, socket) do
      todo = Todos.get_todo!(id)
      Todos.update_todo(todo, %{done: !todo.done})
      {:noreply, socket}
    end

    def handle_event("delete_todo", id, socket) do
      todo = Todos.get_todo!(id)
      Todos.delete_todo(todo)
      {:noreply, socket}
    end

    def handle_event("cancel_edit", _, socket) do
      {:noreply, update(socket, :edit_id, fn _ -> -1 end)}
    end

    def handle_info({Todos, [:todo | _], _}, socket) do
      {:noreply, fetch(socket)}
    end

    defp fetch(socket) do
      assign(socket, todos: Todos.list_todos(), edit_id: -1)
    end

end