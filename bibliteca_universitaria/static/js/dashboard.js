function renderChart(topLibros) {
  const ctx = document.getElementById("chartTopLibros");
  const labels = topLibros.map(l => l[0]);
  const values = topLibros.map(l => l[1]);

  new Chart(ctx, {
    type: "bar",
    data: {
      labels: labels,
      datasets: [{
        label: "Libros más prestados",
        data: values,
        backgroundColor: "rgba(147, 51, 234, 0.8)"
      }]
    },
    options: {
      responsive: true,
      plugins: {
        legend: { display: false },
        title: {
          display: true,
          text: "Top 5 Libros más prestados",
          color: "#fff",
          font: { size: 18 }
        }
      },
      scales: {
        x: { ticks: { color: "#fff" } },
        y: { ticks: { color: "#fff" } }
      }
    }
  });
}
