<?
// MySQL Connection Information
$host = 'wityworks.com';
$user = 'researcher';
$password = 'doyourjob!';
$db = 'research';

// MySQL Link
$link = mysql_connect($host,$user,$password);
if (!$link) {
  die('Could not connect: ' . mysql_error());
}
if (!mysql_select_db($db)) {
  die('Could not find the database: ' . $db); 
}
// Set the character set as UTF8.
mysql_query('SET NAMES "utf8" COLLATE "utf8_general_ci"', $link);

// Added the new review.
function addResult($data, $clipIds) {
  $fields = array_merge(array('pid', 'regtime'), $clipIds);
  $query = "INSERT INTO pororo3 (" . implode(',', $fields) . ") VALUES (" . 
    _values($data, $fields, 1) . ");";
  $result = mysql_query($query);
  $message = mysql_error();
  if (!$result) {
    if (false !== strpos($message, 'Duplicate')) {
      return -1;
    } else {
      die('Invalid query: ' . $message . ' ' . $query);
    }
  } else {
    return 0;
  }
}

// Generate key-value pairs for updating query.
function _pairs($data, $fields) {
  $delimiter = '|;,;|';
  $result = _values($data, $fields, $data['status'], $delimiter);
  $result = explode($delimiter, $result);
  for ($i = 0; $i < count($result); $i++) {
    $result[$i] = $fields[$i] . ' = ' . $result[$i];
  }
  return implode(', ', $result);
}

// Generate a value part of the query.
function _values($data, $fields, $status = 0, $delimiter = ', ') {
  $result = array();
  for ($i = 0; $i < count($fields); $i++) {
    $field = $fields[$i];
    $value = isset($data[$field]) ? $data[$field] : '';
    if ('password' == $field) {
      array_push($result, "PASSWORD('" . 
        mysql_escape_string($value) . "')");
    } else if ('regtime' == $field) {
      array_push($result, 'NOW()');
    } else if ('modtime' == $field) {
      array_push($result, 'NOW()');
    } else if ('status' == $field) {
      array_push($result, $status); // default status is zero as invalid.
    } else if (is_numeric($value)) {
      array_push($result, $value);
    } else if (is_array($value)) {
      array_push($result, "'" . mysql_escape_string(implode(';', $value)) . "'");
    } else {
      array_push($result, "'" . mysql_escape_string($value) . "'");
    }
  }
  return implode($delimiter, $result);
}