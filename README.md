# AMI-Builder
DevSecOps Architecture for a Virtual Enterprise – AMI Builder Repo

## 프로젝트 개요
- **목표**: 보안이 강화된 Ubuntu AMI 생성.
- **기술**: Packer, Ansible
- **주요 기능**:
  - CIS 보안 사항에 중점을 둔 AMI 생성

**디렉토리 구조**
```
├── CloudFence.pkr.hcl
   ├── variables.pkr.hcl
   └── ansible/
       ├── playbook.yml
       ├── requirements.yml
       └── vars/
            └── cis-config.yml
```

## 작업 내용 요약

이 프로젝트에서는 보안 기준을 강화한 Ubuntu AMI 이미지를 자동으로 빌드하고 검사하는 파이프라인을 구성했습니다. 주요 작업 내용은 다음과 같습니다:

### 1. AMI 자동화 빌드
- **Packer**를 사용하여 AMI 이미지를 자동으로 생성합니다.
- **Ansible**을 통해 CIS Benchmark 기반 하드닝을 수행합니다.

### 2. GitHub Actions + OIDC 인증
- AWS IAM Role을 GitHub OIDC를 통해 인증받아, Access Key 없이 CI를 수행합니다.
- OIDC Trust Policy에 프로젝트 레포를 적용하여 해당 레포에서만 인증이 가능하도록 하였습니다.
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::502676416967:oidc-provider/token.actions.githubusercontent.com"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringLike": {
                    "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
                    "token.actions.githubusercontent.com:sub": [
                        "repo:yunhoch0i/AMI-Builder:ref:refs/heads/main",
                        "repo:yunhoch0i/AMI-Builder:ref:refs/heads/main",
                        "repo:WHS-DevSecOps-infra/AMI-Builder:ref:refs/heads/main"
                    ]
                }
            }
        }
    ]
}
```

### 3. Trivy 취약점 검사
- Packer 빌드 도중 마지막에 **Trivy**를 설치하고 루트 파일 시스템(`/`)을 스캔합니다.
- **HIGH, CRITICAL** 수준의 취약점이 발견되면 AMI 빌드를 중단시켜 보안을 보장합니다.
- 취약점 로그는 GitHub Actions에서 바로 확인 가능합니다.



아래 명령어를 통해 로컬로 테스트 가능 
```bash
AWS_PROFILE=<sso_name> packer build -var-file=variables.pkrvars.hcl CloudFence.pkr.hcl
```