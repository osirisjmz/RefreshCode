document.addEventListener("DOMContentLoaded", () => {
    const cards = document.querySelectorAll(".category-card");
    const menu = document.getElementById("context-menu");
    let selectedCategory = null;

    // --- CLICK IZQUIERDO: entrar directamente al catálogo ---
    cards.forEach(card => {
        card.addEventListener("click", (e) => {
            selectedCategory = card.dataset.category;
            logAction("/", "CLICK_CATEGORY", `Categoría seleccionada: ${selectedCategory}`);
            window.location.href = `/catalog/${encodeURIComponent(selectedCategory)}`;
        });
    });

    // --- CLICK DERECHO: mostrar menú contextual ---
    cards.forEach(card => {
        card.addEventListener("contextmenu", (e) => {
            e.preventDefault();
            selectedCategory = card.dataset.category;

            // Mostrar menú contextual donde se hizo clic
            menu.style.display = "block";
            menu.style.top = `${e.pageY}px`;
            menu.style.left = `${e.pageX}px`;
        });
    });

    // --- Ocultar el menú contextual al hacer clic fuera ---
    document.addEventListener("click", () => {
        menu.style.display = "none";
    });

    // --- Acciones del menú contextual ---
    document.getElementById("view-details").addEventListener("click", () => {
        logAction("/catalog", "VIEW_DETAILS", `Categoría: ${selectedCategory}`);
        window.location.href = `/catalog/${encodeURIComponent(selectedCategory)}`;
    });

    document.getElementById("loan-book").addEventListener("click", () => {
        logAction("/prestamo", "LOAN_REQUEST", `Categoría: ${selectedCategory}`);
        window.location.href = `/prestamo/${encodeURIComponent(selectedCategory)}`;
    });

    document.getElementById("reserve-book").addEventListener("click", () => {
        logAction("/reserva", "RESERVE_REQUEST", `Categoría: ${selectedCategory}`);
        window.location.href = `/reserva/${encodeURIComponent(selectedCategory)}`;
    });
});

// --- REGISTRO DE LOGS EN BACKEND ---
function logAction(sitio, accion, detalle) {
    fetch("/log_action", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ sitio, accion, detalle })
    }).catch(err => console.error("Error enviando log:", err));
}
