resource "aws_subnet" "private" {
  count = var.no_of_pri_subs

  vpc_id = aws_vpc.vpc.id
  cidr_block = cidrsubnet(aws_vpc.vpc.cidr_block, 2, count.index)
  availability_zone = data.aws_availability_zones.azs.names[count.index % length(data.aws_availability_zones.azs.names)]

  tags = {
    Name                                    = "${var.env}-private-${count.index+1}"
    "kubernetes.io/cluster/${var.eks_name}" = "owned"
    "kubernetes.io/role/internal-elb"       = "1"
  }
}

resource "aws_subnet" "public" {
  count = var.no_of_pub_subs

  vpc_id = aws_vpc.vpc.id
  cidr_block = cidrsubnet(aws_vpc.vpc.cidr_block, 2, count.index+var.no_of_pri_subs)
  availability_zone = data.aws_availability_zones.azs.names[count.index % length(data.aws_availability_zones.azs.names)]
  map_public_ip_on_launch = true

  tags = {
    Name                                    = "${var.env}-public-${count.index+1}"
    "kubernetes.io/cluster/${var.eks_name}" = "owned"
    "kubernetes.io/role/elb"                = "1"
  }
}