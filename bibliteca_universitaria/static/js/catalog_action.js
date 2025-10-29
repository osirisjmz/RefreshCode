document.addEventListener("DOMContentLoaded", () => {
  const rows = document.querySelectorAll(".book-row");
  const menu = document.getElementById("context-menu");
  let selectedBook = null;

  rows.forEach(row => {
    row.addEventListener("contextmenu", (e) => {
      e.preventDefault();
      selectedBook = {
        id: row.dataset.id,
        title: row.dataset.title
      };
      menu.style.display = "block";
      menu.style.top = `${e.pageY}px`;
      menu.style.left = `${e.pageX}px`;
    });
  });

  document.addEventListener("click", () => menu.style.display = "none");

  document.getElementById("loan-book").addEventListener("click", () => {
    logAction("/prestamo", "LOAN_START", `Libro: ${selectedBook.title}`);
    window.location.href = `/prestamo/${selectedBook.id}`;
  });

  document.getElementById("reserve-book").addEventListener("click", () => {
    logAction("/reserva", "RESERVE_START", `Libro: ${selectedBook.title}`);
    window.location.href = `/reserva/${selectedBook.id}`;
  });
});

function logAction(sitio, accion, detalle) {
  fetch("/log_action", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ sitio, accion, detalle })
  });
}
