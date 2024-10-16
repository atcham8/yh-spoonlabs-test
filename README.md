terraform apply 하기 전 준비사항

1. IAM 사용자 생성 및 권한 설정.
  - 루트유저에서 IAM 서비스를 통해 사용자 추가
  - Create policy로 정책생성
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:*",
        "eks:*",
        "iam:*",
        "elasticloadbalancing:*",
        "cloudwatch:*",
        "logs:*",
        "s3:*",
        "autoscaling:*"
      ],
      "Resource": "*"
    }
  ]
}


    
2.   EKS 관리를 위한 kubectl, aws cli 설치 필요
3.   이후 kubectl apply -f deployment.yaml 명령어를 사용하여 샘플 앱 배포
