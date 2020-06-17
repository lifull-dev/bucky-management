if (gon.controller_name == "test_reports" && gon.action_name == "show") {
    new Chart('test-report-detail-chart', {
    type: 'pie',
    data: {
      labels: ['Passed', 'Failed'],
      datasets: [{
        data: [
          gon.passed_count,
          gon.failed_count,
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

  var path = window.location.pathname;
  var regex = RegExp('^/test_reports\/[0-9]');
  if (regex.test(path)){
    $(function() {
      $(document).ready(function() {
          setInterval(function() {
              jQuery.ajax({
              url: path,
              type: "GET",
              dataType: "script"
              });
          }, 10000); // In every 10 seconds
      });
    });
  }
}