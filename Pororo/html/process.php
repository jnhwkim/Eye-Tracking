<?php
session_start();
require_once('sql.php');

# Test ID
$TestId = 'Pororo Memory Test';
$TestDesc = 'How accurately do you remember what you had seen?';
# Participant Information
$ParticipantId = 'jhkim';
$Test1Date = '2014-04-28';
$Test2Date = '2014-05-08';

$result = addResult($_POST, $_SESSION['clipIds']);

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
    <div class="spacy">&nbsp;</div>
    <div class="container" role="main">
      <div class="well text-center">
        <p>
          <? if(0 == $result) { ?>
          정상적으로 작성된 설문지가 서버로 전송되었습니다. 
          <? } else if(-1 == $result) { ?>
          이미 설문지를 작성하셨습니다.
          <? } ?>
        </p>
        <p>
          참여해주셔서 감사합니다.
        </p>
      </div>
    </div>
  </body>
</html>
