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

var element = document.getElementsByName("check_status");
Object.keys(element).forEach((select) => {
  var a = element[select].value;
  if ( a == "1" ) {
    element[select].className="select_1";
  } else if ( a == "2" ) {
    element[select].className="select_2";
  } else if ( a == "3" ) {
    element[select].className="select_3";
  } else if ( a == "4" ) {
    element[select].className="select_4";
  }
});