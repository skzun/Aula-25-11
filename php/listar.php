<?php
include "conexao.php";

$mes = $_GET["mes"] ?? date("Y-m");

$sql  = "SELECT id, dia, atividade FROM atividades WHERE DATE_FORMAT(dia, '%Y-%m') = ? ORDER BY dia, id";
$stmt = $conexao->prepare($sql);
$stmt->bind_param("s", $mes);
$stmt->execute();
$resultado = $stmt->get_result();

$atividades = array();

while ($linha = $resultado->fetch_assoc()) {
    $linha["id"] = intval($linha["id"]);
    $atividades[] = $linha;
}

echo json_encode($atividades, JSON_UNESCAPED_UNICODE);

$stmt->close();
$conexao->close();
?>
