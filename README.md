# NGG-NewEra

Bản hiện đại hóa độc lập của gamemode SA-MP Next Generation Gaming dành cho open.mp.

Mã nguồn gốc thuộc về các tác giả tương ứng. Đây là dự án không chính thức, không có liên kết với Next Generation Gaming, LLC. Xem [mã nguồn gốc](https://github.com/NextGenerationGamingLLC/SA-MP-Development) để biết thông tin tác giả và các thông báo áp dụng.

## Lý do phát triển

NGG-NewEra duy trì và cải tiến một gamemode đã ngừng cập nhật từ năm 2017. Quá trình phát triển tập trung vào:

- Hỗ trợ open.mp và các thư viện được cập nhật thông qua môi trường do sampctl quản lý.
- Khắc phục các lỗi tồn đọng trong lối chơi, lệnh, tải và lưu dữ liệu.
- Cải thiện hiệu năng và việc dọn dẹp tài nguyên của bộ định thời, công việc và các thực thể trong thế giới trò chơi.
- Bảo vệ thông tin xác thực tài khoản, giao dịch của người chơi và việc chuyển quyền sở hữu.
- Đơn giản hóa mã nguồn cũ và tổ chức lại các hệ thống để dễ bảo trì hơn.

Mục tiêu là giải quyết gần như toàn bộ vấn đề đã xác định trong mã nguồn cũ, đồng thời giữ nguyên lối chơi cốt lõi và dữ liệu hiện có. Các bản sửa lỗi và cải tiến đã hoàn tất được ghi trong [lịch sử thay đổi](CHANGES.md).

## Yêu cầu

- Cài đặt [sampctl](https://github.com/Southclaws/sampctl/blob/master/docs/install.md).
- Khuyến nghị sử dụng [MariaDB](https://mariadb.org/download/).

## Thiết lập cơ sở dữ liệu

Tạo cơ sở dữ liệu và tài khoản có quyền truy cập, sau đó nhập [database/ngrp.sql](database/ngrp.sql).

Cập nhật thông tin kết nối trong [scriptfiles/mysql.cfg](scriptfiles/mysql.cfg):

```ini
HOST=127.0.0.1
PORT=3306
DB=ngrp
USER=ngrp
PASS=your_database_password
SERVER=1
BETASERVER=1
SHOPAUTOMATED=0
```

`SERVER` là mã định danh của máy chủ. Đặt `BETASERVER=1` khi thử nghiệm hoặc `0` khi vận hành máy chủ thông thường.
Để bật cơ sở dữ liệu riêng cho shop, đặt `SHOPAUTOMATED=1` và cấu hình `SHOST`, `SDB`, `SUSER`, `SPASS`.

## Biên dịch và chạy

Chạy các lệnh sau tại thư mục gốc của mã nguồn:

```sh
sampctl ensure
sampctl build
sampctl run
```

Quá trình biên dịch tạo ra tệp `gamemodes/NGRP.amx`. Cấu hình các thiết lập máy chủ tại mục `runtime` trong [pawn.json](pawn.json).
