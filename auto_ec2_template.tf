resource "aws_launch_template" "httpd-ec2" {
  name = "httpd-ec2"

  # 디스크 볼륨, 이름 지정
  block_device_mappings {
    device_name = "/dev/sdf"

    ebs {
      volume_size = 8
    }
  }

  # 인스턴스 중지 및 종료 방지
  disable_api_stop        = true
  disable_api_termination = true

  # 서버 이미지 설정
  image_id = var.amazon_linux_2023_id

  # 인스턴스가 운영 체제(OS) 셧다운 명령을 받았을 때 어떤 동작을 할지를 지정
  # 기본 stop(중지)
  instance_initiated_shutdown_behavior = "terminate" # 종료

  # 인스턴스 유형 설정
  instance_type = "t2.micro"

  # security group 설정
  vpc_security_group_ids = [aws_security_group.auto_sg.id]

  # 태그 설정
  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${aws_vpc.auto-vpc.tags.Name}-auto-scaling"
    }
  }

  # 서버 부팅시 기초 세팅 설정
  user_data = filebase64("${path.module}/init_file/setup.sh")
}