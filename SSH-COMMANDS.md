# Commands (Host → Server → Nodes)

> Mục tiêu: từ máy host (macOS) vào container `ansible-server` bằng `docker exec` (không cần SSH/mật khẩu), rồi từ `ansible-server` SSH vào `node1/node2` theo kiểu key-based (không nhập mật khẩu).

## 0) Khởi động đúng mô hình (host)

```bash
# Dọn container cũ (nếu có)
docker rm -f ansible-server node1 node2 2>/dev/null || true

# Tạo network để các container resolve nhau theo tên (node1/node2)
docker network create ansible-net 2>/dev/null || true

# Chạy 2 node trước (sshd trong node cần vài giây để sẵn sàng)
docker run -d --name node1 --hostname node1 --network ansible-net ansible-node1:latest
docker run -d --name node2 --hostname node2 --network ansible-net ansible-node2:latest

# Chạy ansible-server sau (không cần -p vì host vào bằng docker exec)
docker run -d --name ansible-server --hostname ansible-server --network ansible-net ansible-server:latest

# Kiểm tra trạng thái
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}' | egrep '^(NAMES|ansible-server|node1|node2)\b'
```

## 1) Host vào server bằng docker exec (không cần mật khẩu)

```bash
# Vào root shell trong container ansible-server
docker exec -it ansible-server bash

# (Tuỳ chọn) Vào shell với user ansible-server
docker exec -it -u ansible-server ansible-server bash
```

## 2) SSH từ server vào node (không nhập mật khẩu)

Bạn đang đăng nhập trong server bằng user `ansible-server`. Key để SSH sang node được tạo/copy bởi entrypoint dưới user `root` (nằm ở `/root/.ssh/id_ed25519`).

Vì vậy dùng `sudo` + chỉ rõ key path để ép dùng publickey (không nhập password):

```bash
# Vào node1 (từ trong ansible-server)
sudo ssh -i /root/.ssh/id_ed25519 root@node1

# Vào node2 (từ trong ansible-server)
sudo ssh -i /root/.ssh/id_ed25519 root@node2
```

Nếu SSH hỏi xác nhận host key lần đầu:

```bash
sudo ssh -i /root/.ssh/id_ed25519 -o StrictHostKeyChecking=no root@node1
sudo ssh -i /root/.ssh/id_ed25519 -o StrictHostKeyChecking=no root@node2

# (Tuỳ chọn) Fail ngay nếu SSH đang rơi về password (dùng để test nhanh)
sudo ssh -i /root/.ssh/id_ed25519 -o BatchMode=yes root@node1 'echo OK_NODE1'
sudo ssh -i /root/.ssh/id_ed25519 -o BatchMode=yes root@node2 'echo OK_NODE2'
```
