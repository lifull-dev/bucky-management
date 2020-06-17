if (gon.controller_name == "pages" && gon.action_name == "main") {
    Object.keys(gon.data_for_top).forEach((chart) => {
      if (gon.data_for_top[chart]) {
        new Chart(gon.data_for_top[chart].title_name, {
          type: 'pie',
          data: {
            labels: ['Passed', 'Failed'],
            datasets: [{
              data: [
                gon.data_for_top[chart].latest_passed_count,
                gon.data_for_top[chart].latest_failed_count,
              ],
              backgroundColor: [
                'rgba(75, 192, 192, 0.5)',
                'rgba(255, 99, 132, 0.5)',
              ],
              borderColor: [
                'rgba(75, 192, 192, 1)',
                'rgba(255,99,132,1)',
              ],
              borderWidth: 1,
            }],
          },
        });
      }
    });
}