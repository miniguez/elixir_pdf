defmodule ElixirPdfWeb.HomeLive do
  use ElixirPdfWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:uploaded_files, [])
     |> allow_upload(:pdf,
       accept: ~w(.pdf),
       max_entries: 1,
       # 10MB limit
       max_file_size: 10_000_000,
       chunk_size: 64_000
     )}
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("save", _params, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :pdf, fn %{path: path}, _entry ->
        dest = Path.join(["priv", "static", "uploads", Path.basename(path)])
        File.cp!(path, dest)
        {:ok, dest}
      end)

    pdf_document =
      uploaded_files
      |> hd()
      |> RustReader.extract_pdf()
      |> ElixirPdf.PdfDocument.from_rustler()
      |> IO.inspect()

    {:noreply,
     socket
     |> assign(:pdf_document, pdf_document)
     |> update(:uploaded_files, &(&1 ++ uploaded_files))}
  end
end
