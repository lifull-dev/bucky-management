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
