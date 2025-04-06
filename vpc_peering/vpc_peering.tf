# ================================================================
# VPC Peeringの設定
# ================================================================
#
# VPC Peeringはリクエスタ側に作る。peer_vpc_idにAcceptor側のVPCを指定する。
#
resource "aws_vpc_peering_connection" "peering" {
  vpc_id      = aws_vpc.requester.id
  peer_vpc_id = aws_vpc.acceptor.id
  auto_accept = true # 異なるアカウント間の場合はfalseにし、別途追加の設定が必要。

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags = {
    Name = "${local.requester_name}-peering"
  }

  depends_on = [aws_vpc.requester, aws_vpc.acceptor]
}
#
# Requester側のRTB設定
#
resource "aws_route" "requester_peer" {
  route_table_id            = aws_route_table.requester.id
  destination_cidr_block    = aws_vpc.acceptor.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering.id

  depends_on = [aws_vpc_peering_connection.peering]
}
#
# Acceptor側のRTB設定
#
resource "aws_route" "acceptor_peer" {
  route_table_id            = aws_route_table.acceptor.id
  destination_cidr_block    = aws_vpc.requester.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering.id

  depends_on = [aws_vpc_peering_connection.peering]
}
