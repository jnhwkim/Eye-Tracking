<?php
session_start();

# Test ID
$TestId = 'Pororo Memory Test';
$TestDesc = 'How accurately do you remember what you had seen?';
# Participant Information
$ParticipantId = $_GET['p'];
if (!isset($ParticipantId)) {
  header("Location: " . 'http://wityworks.com');
}
# Clip IDs
$types = array('L', 'S', 'C');
$clipIds = array();
foreach($types as $type) {
  if ($type == 'C') {
    $length = 4;
  } else {
    $length = 8;
  }
  for ($i = 1; $i <= $length; $i++) {
    array_push($clipIds, $type.'_'.$i);
  }
}
shuffle($clipIds);
$_SESSION['clipIds'] = $clipIds;
?>
<!DOCTYPE html>
<html lang="ko">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="Pororo Season 3 LTM Test Sheet">
    <meta name="author" content="jnhwkim">
    <link rel="shortcut icon" href="favicon.ico">

    <title><?=$TestId?> (<?=$ParticipantId?>)</title>

    <!-- Latest compiled and minified CSS -->
    <link rel="stylesheet" href="//netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css">
    <!-- Latest compiled and minified CSS -->
    <link rel="stylesheet" href="//netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap-theme.min.css">
    <!-- Custom styles for this template -->
    <link href="css/index.css" rel="stylesheet">

    <!-- Just for debugging purposes. Don't actually copy this line! -->
    <!--[if lt IE 9]><script src="../../assets/js/ie8-responsive-file-warning.js"></script><![endif]-->

    <!-- HTML5 shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!--[if lt IE 9]>
      <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
      <script src="https://oss.maxcdn.com/libs/respond.js/1.4.2/respond.min.js"></script>
    <![endif]-->
  </head>
  <body role="document">
    <!-- Bootstrap core JavaScript
    ================================================== -->
    <!-- Placed at the end of the document so the pages load faster -->
    <!-- Due to the fileupload's process, I moved the calling js to here. -->
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"></script>
    <!-- Latest compiled and minified JavaScript -->
    <script src="//netdna.bootstrapcdn.com/bootstrap/3.1.1/js/bootstrap.min.js"></script>
    <!-- Alert message would be shown here. -->
    <div class="alert"></div>

    <div class="container" role="main">
      <div class="page-header">
        <h1><?=$TestId?> <small></small></h1>
      </div>
      <ul class="list-unstyled">
        <li><label class="participant-info-label">Participant ID: </label>
        <span class="participant-info-id"><?=$ParticipantId?></span>
        </li>
      </ul>
      <div class="jumbotron">
        <p>본 설문지는 약 3개월 전에 &lt;뽀로로 시즌 3&gt;를 시청한 참여자를 대상으로 영상 내용을 어느 정도로 기억하는지를 측정합니다.</p>
        <p>아래에는 3초 분량의 비디오 클립 20개가 포함되어 있는데, 본 내용과 보지 않은 내용이 무작위로 나열되어 있습니다. 각 비디오 클립에는 1점부터 5점까지 척도로 여부를 체크할 수 있는데, 보지 않았다라고 확신한다면 1점, 본 내용이다라고 확신한다면 5점을 체크하시면 됩니다.</p>
        <p>먼저 20개의 비디오 클립 전체를 훝어본 후 진행한다면 적절한 확신도를 체크하는데 도움을 얻을 수 있습니다.</p> 
      </div>
      <form class="form-horizontal" role="role" method="post" action="process.php">
        <input type="hidden" name="pid" value="<?=$ParticipantId?>">
        <? foreach($clipIds as $clipId) { ?>
        <div class="panel panel-default" id="<?=$clipId?>">
          <div class="panel-body form-group">
            <div class="panel-clip col-sm-6">
              <img src="img/animated_gif/<?=$ParticipantId?>/<?=$clipId?>.gif">
            </div>
            <div class="panel-vote col-sm-5">
              <input name="<?=$clipId?>" type="number" class="rating" min=0 max=5 step=1 data-size="sm" >
            </div>
          </div>
        </div>
        <? } ?>
        <div class="spacy text-center">
          <button class="btn btn-primary" type="submit">작성 완료</button>
        </div>
      </form>
      <div class="spacy"></div>
      <div class="spacy"></div>
      <div class="spacy"></div>
    </div>
    <script type="text/javascript" src="js/bootstrapValidator.min.js"></script>
    <link href="bootstrap-star-rating/css/star-rating.min.css" media="all" rel="stylesheet" type="text/css" />
    <script src="bootstrap-star-rating/js/star-rating.min.js" type="text/javascript"></script>
    <script type="text/javascript">
    // Star Rating
    $(".rating").rating({
      showClear: false,
      clearCaption:'미체크',
      starCaptions:{
        0.5: '0.5점', 1: '보지 않음',
        1.5: '1.5점', 2: '안 본 듯',
        2.5: '2.5점', 3: '불확실',
        3.5: '3.5점', 4: '본 듯',
        4.5: '4.5점', 5: '확실히 보았음'
      }
    });
    </script>
  </body>
</html>
