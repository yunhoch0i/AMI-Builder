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