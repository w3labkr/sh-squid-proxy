# Squid Proxy Installer

이 프로젝트는 **Ubuntu 기반 리눅스 서버**에 **Squid 프록시 서버**를 자동으로 설치해주는 스크립트입니다.  
유동 IP 환경에서도 안정적으로 사용할 수 있도록 **ID/PW 기반 인증 접속**을 지원하며, 실전 크롤링 및 프록시 운영에 유용한 다양한 기능이 포함되어 있습니다.

## 주요 기능

- **ID/PW 인증 기반 Squid 프록시 서버** 자동 설치
- **포트 변경 기능** 제공 (기본 포트: `54821`) – 기본 포트 감지를 피하기 위해 유용
- **30일간 로그 보관** (logrotate 적용)
- **Fail2ban을 통한 보안 강화** – SSH 브루트포스 공격 차단
- **프록시 헤더 제거**를 통한 익명성 향상
- **서비스 장애 시 자동 재시작** 기능 (crontab 활용)

## 설치 방법

### Git 저장소 이용

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

`install.sh` 파일을 수정하여 사용자명과 포트를 자유롭게 변경할 수 있습니다.

- 프록시 주소: http://<서버 IP>:54821
- 사용자명: proxyuser
- 비밀번호: proxy1234
- 화이트리스트: 127.0.0.1

## 자주 사용하는 프록시 포트

| 포트 번호 | 용도 설명                         |
|-----------|----------------------------------|
| 3128      | Squid 프록시 기본 포트           |
| 8080      | 일반적인 HTTP 프록시 포트        |
| 8888      | 개발/테스트용 프록시 포트        |
| 8000      | 로컬 웹 서버용 포트              |
| 1080      | SOCKS 프록시용 (SOCKS4/5)         |
| 443       | HTTPS 기본 포트                  |
| 50000     | 로컬 테스트에 적합한 고유 포트    |
| 54321     | 기억하기 쉬운 테스트용 포트       |
| 60000     | 개인화된 프록시 구성에 적합       |

## 테스트 예시

### Curl을 이용한 테스트

```bash
curl -x http://proxyuser:proxy1234@<서버 IP>:54821 http://ipinfo.io
```

### Python requests 사용 예

```python
import requests

proxies = {
    "http": "http://proxyuser:proxy1234@<서버 IP>:54821",
    "https": "http://proxyuser:proxy1234@<서버 IP>:54821"
}

res = requests.get("http://ipinfo.io", proxies=proxies)
print(res.text)
```

## 시스템 요구사항

- Ubuntu 20.04 / 22.04 / 24.04 이상
- 공개 IP가 할당된 서버 (VPS 또는 클라우드 인스턴스 등)
- `sudo` 권한을 가진 사용자 계정

## 보안 및 운영 팁

- SSH 포트 변경 및 키 인증 설정을 권장합니다.
- 기본적으로 `fail2ban`이 SSH 접속 보호 기능을 수행합니다.
- 트래픽이 많을 경우 연결 수 제한 설정을 고려하세요.
- 공용 네트워크나 다중 사용자 환경에서는 접근 제어가 필수입니다.

## 라이선스

**MIT License**  
본 스크립트는 자유롭게 사용 및 수정할 수 있으며, 사용에 따른 책임은 사용자에게 있습니다.
