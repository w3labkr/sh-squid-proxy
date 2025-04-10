# Squid Proxy Installer

이 프로젝트는 Ubuntu 기반의 리눅스 서버에 **Squid 프록시 서버**를 자동으로 설치하는 스크립트입니다.  
유동 IP 환경에서도 사용할 수 있도록 인증 기반 접속을 제공하며, 실전 크롤링 및 프록시 운영에 필요한 다양한 기능을 포함하고 있습니다.

## 주요 기능

- **ID/PW 인증 프록시 서버** 자동 설치 (Squid)
- **포트 변경 기능**을 통해 기본 포트 감지 회피 (기본 포트: `3128`)
- **30일간 로그 보관** (logrotate 적용)
- **Fail2ban을 통한 보안 강화** (SSH 브루트포스 공격 차단)
- **프록시 헤더 제거**로 익명성 강화
- **서비스 장애 시 자동 재시작** (crontab 활용)

## 설치 방법

### Git 저장소에서 설치

```bash
# Git 설치 (필요한 경우)
sudo apt update && sudo apt install -y git

# 저장소 클론
git clone https://github.com/w3labkr/sh-squid-proxy.git
cd sh-squid-proxy

# 실행 권한 부여 및 설치
chmod +x install.sh
./install.sh
```

## 기본 프록시 정보

- 프록시 주소: `http://<서버 IP>:3128`
- 사용자명: `proxyuser`
- 비밀번호: `proxy1234`

> 필요 시 `install.sh` 파일 내 사용자 정보 및 포트를 직접 수정할 수 있습니다.

## 테스트 예시

### Curl로 테스트

```bash
curl -x http://proxyuser:proxy1234@<서버 IP>:3128 http://ipinfo.io
```

### Python requests 사용 예

```python
import requests

proxies = {
    "http": "http://proxyuser:proxy1234@<서버 IP>:3128",
    "https": "http://proxyuser:proxy1234@<서버 IP>:3128"
}

res = requests.get("http://ipinfo.io", proxies=proxies)
print(res.text)
```

## 시스템 요구사항

- Ubuntu 20.04 / 22.04 / 24.04 이상
- 공개 IP가 할당된 서버 (VPS, 클라우드 인스턴스 등)
- `sudo` 권한 보유 계정

## 보안 및 운영 팁

- SSH 포트 변경 및 키 인증 설정 권장
- 기본적으로 `fail2ban`이 SSH 보호 기능 수행
- 트래픽이 과도할 경우, 연결 수 제한 설정 권장
- 공공 네트워크나 다중 사용자 환경에서는 접근 제어 필수

## 라이선스

MIT License  
본 스크립트는 자유롭게 사용 및 수정이 가능하지만, 사용에 따른 책임은 사용자에게 있습니다.
