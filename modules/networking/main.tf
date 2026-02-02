# יצירת הרשת הפרטית (VPC)
resource "aws_vpc" "ctf_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags                 = { Name = "ctf-vpc" }
}

# תת-רשת ציבורית שמאפשרת כתובת IP חיצונית
resource "aws_subnet" "ctf_subnet" {
  vpc_id                  = aws_vpc.ctf_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true # קריטי לגישה מהבית
  availability_zone       = "eu-central-1a"
  tags                    = { Name = "ctf-subnet" }
}

# הגדרת פיירוול (Security Group)
resource "aws_security_group" "ctf_sg" {
  name   = "ctf-security-group"
  vpc_id = aws_vpc.ctf_vpc.id

  # פתיחת SSH (פורט 22) לגישה מרחוק
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # פתיחת פורט 8000 עבור אתר ה-CTFd
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # יציאה חופשית לאינטרנט כדי שהמכונה תוריד Docker
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# רכיבים הכרחיים לחיבור האינטרנט (IGW)
resource "aws_internet_gateway" "igw" { vpc_id = aws_vpc.ctf_vpc.id }

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.ctf_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.ctf_subnet.id
  route_table_id = aws_route_table.rt.id
}