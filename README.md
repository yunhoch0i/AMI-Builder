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


## CIS Benchmark 적용 예외 규칙
200명 규모의 초기 기업 환경에서의 운영 유연성과 개발 편의성을 위해 CIS Benchmark 규칙의 일부를 비활성화 하였습니다.
모든 Level 1 규칙을 적용하는 것을 기본으로 하되, 아리 목록의 규칙들은 예외 처리가 이루어졌습니다.
```
파티션 분리 규칙
- ubtu20cis_rule_1_1_2_1
- ubtu20cis_rule_1_1_3_1
- ubtu20cis_rule_1_1_4_1
- ubtu20cis_rule_1_1_5_1
- ubtu20cis_rule_1_1_6_1
- ubtu20cis_rule_1_1_7_1
제외 근거: 클라우드 환경에서 파티션을 물리적으로 분리한다면 인스턴스 관리의 복잡성을 높이고 초기 설정 이후의 변경이 어려워 개발이 이루어지는 초기 기업에서 불편함이 증가할 요인으로 판단하여 비활성화


방화벽 기본 정책 규칙
- ubtu20cis_rule_4_3_4
제외 근거: 방화벽 기본 정책을 'Deny All'로 설정하는 정책으로 Trivy 검사를 통한 무결성 검증을 방해하여 비활성화


SSH 접근 제어 규칙
ubtu20cis_rule_6_2_5
제외 근거: 여러 담당자가 시스템에 접근하여 테스트하고 작업을 해야하지만 SSH의 특정 접근을 제한하는 해당 규칙으로 업무 효윻을 떨어뜨릴 수 있다고 판단하여 비활성화

```