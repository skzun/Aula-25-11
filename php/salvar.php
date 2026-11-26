<?php
include "conexao.php";

$dia       = $_POST["dia"] ?? "";
$atividade = trim($_POST["atividade"] ?? "");

if ($dia == "" || $atividade == "") {
    http_response_code(400);
    echo json_encode(array("erro" => "Informe o dia e a atividade."), JSON_UNESCAPED_UNICODE);
    exit;
}

$sql  = "INSERT INTO atividades (dia, atividade) VALUES (?, ?)";
$stmt = $conexao->prepare($sql);
$stmt->bind_param("ss", $dia, $atividade);

if ($stmt->execute()) {
    echo json_encode(array("ok" => true, "id" => $stmt->insert_id), JSON_UNESCAPED_UNICODE);
} else {
    http_response_code(500);
    echo json_encode(array("erro" => $stmt->error), JSON_UNESCAPED_UNICODE);
}

$stmt->close();
$conexao->close();
?>
