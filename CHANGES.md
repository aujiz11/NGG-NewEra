# Lịch sử thay đổi - NG:RP v4.1.18

### Thay đổi

#### Xử lý lệnh và thư viện

- Chuyển xử lý lệnh từ ZCMD sang Pawn.CMD, khai báo bí danh trực tiếp bằng cú pháp của thư viện.
- Loại bỏ các hàm thay thế native tạm thời và đổi tên hàm hỗ trợ của dự án để phân biệt với API thư viện.
- Sử dụng lại `Random(min, max)` của YSI, giữ nguyên giới hạn trên không được lấy.

#### Hệ thống tài khoản và lưu dữ liệu

- Chuyển mã hóa mật khẩu tài khoản và PIN cửa hàng sang samp_bcrypt với cost 10, thay Whirlpool trong cấu hình plugin.
- Khôi phục cập nhật tài khoản theo từng đoạn truy vấn với bộ đệm 2048 ô.
- Bổ sung cấu hình MySQL `PORT` tùy chọn, mặc định là `3306`.

#### Hệ thống ngân hàng và thanh toán tiền mặt

- Thống nhất xử lý chuyển tiền ngân hàng và ATM, giữ nguyên phí và quy tắc giao dịch hiện có.
- Áp dụng cùng giới hạn và điều kiện thanh toán tiền mặt cho `/pay` và menu tương tác.
- Loại bỏ mô phỏng quỹ ngân hàng tổng và các lệnh quản trị liên quan.
- Các lần ghi cuối của ATM, ngân hàng và giao hàng cửa hàng tự động yêu cầu InnoDB, thực thi đồng bộ sau khi hàng đợi MySQL hoàn tất.

#### Hệ thống bầu cử

- Thay các truy vấn kiểm tra trùng bằng một lần chèn phiếu bầu có ràng buộc tại cơ sở dữ liệu.

#### Hệ thống giấy phép súng

- Giới hạn tra cứu lý lịch ở một hồ sơ phạm tội phù hợp.

#### Hệ thống thực thi pháp luật

- Cho các thao tác còng, tháo còng, kéo người, áp giải và phạt tiền trong menu tương tác dùng chung kiểm tra với lệnh.

#### Hệ thống bản đồ và GPS

- Thiết kế lại `/map` với cột khu vực, khoảng cách có đơn vị mét, điểm xin việc đang hoạt động gần nhất và danh sách doanh nghiệp có phân trang.

#### Hệ thống cài đặt tài khoản

- Thống nhất menu và lệnh bật/tắt theo ID kênh đã lưu, ẩn tùy chọn hộp chat chưa hoàn thiện và giao diện điện thoại cũ không hoạt động.

#### Hệ thống lõi nghề nghiệp

- Tập trung định nghĩa và tên mặc định của nghề nghiệp, sử dụng ID liên tiếp và tạo menu từ danh mục nghề.
- Tập trung xử lý đổi ô nghề và dọn hoạt động, dùng chung ngưỡng kỹ năng và tách phần trợ giúp, hiển thị kỹ năng khỏi lõi nghề.
- Thống nhất `/join` và phím Y tại điểm xin việc đã cấu hình, sử dụng một hộp thoại xin việc chung.
- Thống nhất xử lý nghỉ việc, giữ các ô nghề đã sở hữu sau khi VIP hết hạn.
- Loại bỏ nghề Taxi trống và Drugs không hoạt động.

#### Hệ thống nghề câu cá và thu gom rác

- Chuyển Fishing đang hoạt động vào `gamemodes/job/fishing.pwn`, xóa module cũ không sử dụng và bộ nhớ lưu ô cá tương ứng.
- Chuyển nghề thu gom rác vào `gamemodes/includes/jobs/`.

#### Hệ thống nghề chế tạo và buôn vũ khí

- Tập trung công thức của nghề chế tạo và buôn vũ khí, giữ nguyên chi phí, phần thưởng, điều kiện mở khóa và quy tắc kinh nghiệm chế tạo.

#### Hệ thống nghề luật sư, quyền anh và săn kho báu

- Tập trung xử lý chấp nhận dịch vụ và kiểm tra điều kiện của nghề luật sư.
- Tập trung thiết lập, kết quả và dọn trạng thái trận quyền anh trong module riêng.
- Tập trung định nghĩa phần thưởng và bán vật phẩm của nghề săn kho báu, giữ nguyên giá bán.

#### Hệ thống tài sản và lối ra vào

- Thay quét tọa độ và tùy chọn lối vào cũ bằng tra cứu vùng động có phân loại cho `/enter`, `/exit` và phím tắt.
- Giao dịch xe chuyển quyền sở hữu trên bản ghi hiện có, không thay đổi ID trong cơ sở dữ liệu.

#### Hệ thống kho cá nhân

- Giới hạn kho cá nhân ở chuyển tiền mặt và giao vật liệu đang mang, loại bỏ các nhánh vật chứa không sử dụng.

#### Hệ thống bàn chông

- Thay pickup bàn chông bằng kiểm tra tiếp xúc bánh xe của từng người lái.

#### Hệ thống nội thất

- Tách đọc dữ liệu nội thất từ cache khỏi kiểm tra vị trí đặt.

#### Hệ thống thông báo và tài nguyên cũ

- Định dạng thông báo người chơi và toàn máy chủ ngay tại nơi gửi, xóa các bộ đệm không còn sử dụng.
- Tận dụng `GetVehicleName` để lấy tên xe đang hoạt động, xóa bộ đệm giải mã dư thừa.
- Xóa các bản triển khai hướng dẫn không sử dụng và tài nguyên giao diện cũ đi kèm.

### Khắc phục

#### Hệ thống cứu thương

- Sửa dọn trạng thái cáng và kiểm tra phiên kết nối, ngăn thao tác đã hủy hoặc slot tái sử dụng di chuyển nhầm bệnh nhân.
- Đưa bệnh nhân được di chuyển vào đúng interior và virtual world của nhân viên cứu thương.
- Sửa chọn bệnh nhân trong danh sách EMS và ngăn nhận trùng cuộc gọi.
- Sửa nhận diện xe cứu thương và đưa bệnh nhân lên xe với kiểm tra ghế, khoảng cách và không gian.
- Thống nhất điều trị qua menu với quyền hạn và kiểm tra thanh toán của lệnh, áp dụng phí hồi máu $1.000.
- Chặn trả thưởng giao bệnh nhân khi quỹ tổ chức không đủ hoặc bệnh viện hết giường.

#### Hệ thống bầu cử

- Giữ ID ứng viên liên tiếp và loại bỏ dòng trống đầu tiên trong menu.
- Đếm phiếu từng đợt bầu cử mà không cộng dồn kết quả từ lần đếm hoặc đợt trước.
- Từ chối menu cũ sau khi danh sách ứng viên hoặc trạng thái bầu cử thay đổi.

#### Hệ thống kéo và tạm giữ xe

- Lưu xe cá nhân bị tạm giữ theo đúng chủ sở hữu, không chạy tiếp vào nhánh hồi sinh xe chưa đăng ký.
- Tháo xe bị tạm giữ và dọn tham chiếu kéo xe, lối vào và thao tác thùng hàng đang chờ trước khi thu hồi tài nguyên.
- Lưu tiền thưởng tạm giữ xe của tổ chức.

#### Hệ thống lương và ngân sách tổ chức

- Gộp trừ quỹ tổ chức và cộng ngân hàng thành viên trong một câu SQL, từ chối khi thiếu quỹ hoặc vượt giới hạn số dư người nhận.
- Sửa định dạng số tiền trong nhật ký chỉnh sửa ngân sách chính phủ.

#### Hệ thống giấy phép súng

- Kiểm tra lại tiền mặt và yêu cầu người xin giấy phép ở điểm cấp phép tại Tòa thị chính cho đến khi duyệt.
- Hủy hồ sơ đang chờ khi giấy phép được cấp hoặc thu hồi thủ công.
- Áp dụng thời hạn giấy phép thống nhất tại MDC và cửa hàng súng.
- Sửa định dạng ID tài khoản trong nhật ký thu hồi giấy phép.

#### Hệ thống thực thi pháp luật

- Sửa kiểm tra khoảng cách xe khi áp giải, dừng kéo người khi mất kết nối, chết, lên xe hoặc không còn bị khống chế.
- Khôi phục chuyển Code 2 và Code 3 của `/backup`, dọn yêu cầu hỗ trợ sau khi đổi tổ chức.
- Lưu ngay vé phạt xe và việc thu giữ vũ khí trong cốp.
- Sửa kiểm tra đăng ký xe đang được kéo và thông báo cốp trống mâu thuẫn sau khi khám xe.
- Lưu lý do phạt ở người nhận để xử lý `/accept ticket`.
- Chọn xe gần người chơi trong đúng virtual world và interior.

#### Hệ thống vũ khí tổ chức

- Lưu vật liệu tủ vũ khí sau khi cất hoặc lấy, kiểm tra đúng vũ khí sở hữu trước khi cho cất.
- Kiểm tra lại quyền dùng tủ và duyệt vũ khí, từ chối yêu cầu hết hạn hoặc thay đổi tổ chức hay ô vũ khí.
- Khớp các dòng menu vũ khí, cấp bậc với ô đã cấu hình, chặn hộp thoại két vũ khí cũ.
- Ngăn tràn số lượng vật liệu và thùng hàng khi chuyển qua tủ vũ khí.
- Lưu kết quả chuyển tủ vũ khí cũ, giữ lượng vũ khí chưa có chi phí dương, dùng đúng ID bản ghi và các cột thực sự tồn tại.
- Kiểm tra lại quyền lãnh đạo và thời gian chờ thu hồi thùng chuyển kho, chặn triển khai trùng và lựa chọn tài nguyên đã thay đổi.
- Giữ lại vũ khí mà tủ đích không nhận được, sửa lấy tên xe trong `/gunloadcrate` theo ID xe đang hoạt động.

#### Hệ thống thùng hàng và cơ sở sản xuất

- Nạp thùng hàng, cơ sở sản xuất và đơn đặt hàng theo ID bản ghi cố định.
- Cộng vật liệu theo số thùng thực tế đã dùng, giữ lượng thùng khi chuyển từ xe sang xe nâng.
- Sửa thanh toán và hoàn quỹ bằng số nguyên, lưu tiền giao hàng cho đúng tổ chức nhận.
- Hủy thao tác khi người chơi, xe, cơ sở hoặc đơn hàng không còn hợp lệ, chặn hộp thoại cũ ghi đè đơn đang hoạt động.
- Kiểm tra lựa chọn vũ khí và tính lại sản lượng theo thùng sẵn sàng cùng thùng đang được sử dụng.

#### Hệ thống lãnh thổ

- Nạp lãnh thổ theo ID cơ sở dữ liệu, bỏ qua bản ghi sai định dạng mà không ghi đè dữ liệu đã lưu.
- Giữ đầy đủ dữ liệu lãnh thổ đã tuần tự hóa và thiết lập sở hữu khi lưu hoặc đổi kích thước.
- Kiểm tra lại quyền chỉnh sửa, giới hạn ID lãnh thổ, tổ chức và dữ liệu số trước khi áp dụng thay đổi.
- Loại chủ sở hữu không phải tổ chức khỏi thuế và thưởng tổ chức, ngăn tràn số khi tính toán.

#### Hệ thống cổng

- Nạp cổng theo ID cơ sở dữ liệu, kiểm tra ID và lựa chọn chỉnh sửa trước khi đổi dữ liệu.
- Sửa vị trí mở, đóng trong trình chỉnh sửa, vô hiệu hóa timer và callback cũ sau khi tạo lại hoặc xóa cổng.
- Đặt lại và lưu đầy đủ cấu hình cổng khi xóa.
- Lưu thay đổi khóa cổng và khôi phục quyền khóa của quản lý tổ chức.
- Áp dụng giới hạn virtual world, interior và giữ trạng thái điều khiển riêng của cơ sở khi dùng lệnh hoặc tạo lại đối tượng.
- Bắt đầu đếm thời gian tự đóng sau khi cổng mở xong.
- Áp dụng thay đổi vật liệu bề mặt ngay lập tức bằng màu RGB không trong suốt.
- Sửa phí di chuyển cổng, gồm miễn phí khi tỷ lệ bằng không.
- Ẩn mật khẩu khỏi thông báo trạng thái và xác nhận.

#### Hệ thống cửa động

- Kiểm tra ID cửa, tổ chức trước khi truy cập mảng, đặt lại đầy đủ quyền sở hữu và cấu hình khi xóa.
- Lưu thay đổi khóa của chủ sở hữu, lãnh đạo tổ chức mà không cắt ngắn câu SQL, nhãn cửa hoặc nhật ký đổi tên.
- Sửa phí di chuyển cửa và miễn phí khi tỷ lệ bằng không.
- Áp dụng thống nhất điều kiện Dedicated Player khi vào và ra, kiểm tra GroupType độc lập với Allegiance.
- Giới hạn pickup trong interior đã cấu hình, chặn đi vào khi chưa có tọa độ nội thất.

#### Hệ thống bản đồ và GPS

- Kiểm tra địa chỉ và lựa chọn điểm đến, sửa tra cứu khu vực doanh nghiệp và cửa.
- Giữ checkpoint đang hoạt động khi mở bản đồ, sửa nhận biết đã đến điểm đích.

#### Hệ thống cài đặt tài khoản và kênh thông tin

- Sửa hiển thị trạng thái bật/tắt và giữ đúng ID lựa chọn khi vai trò người chơi thay đổi lúc menu đang mở.
- Áp dụng thống nhất tùy chọn Global OOC, News, Whispers, Bug Chat và Point Messages cho các thông báo tương ứng.
- Gửi bản tin truyền hình đến đầy đủ người nhận và giữ quyền quản trị viên đối với tin nhắn thì thầm.
- Khôi phục tùy chọn HUD RepFam khi người chơi đổi trạng thái đại diện băng nhóm.

#### Hệ thống lõi nghề nghiệp

- Đồng bộ tên lưu trong dữ liệu và ID trợ giúp với danh mục nghề liên tiếp, dùng tên mặc định khi SQL thiếu tên hoặc còn tên giữ chỗ.
- Xóa mục kỹ năng Drug Dealer sai do đọc dữ liệu cây trồng thành kỹ năng người chơi.
- Chặn xin nghề cũ hoặc chưa triển khai, kiểm tra lại vị trí, cấp độ và ô nghề trống khi xác nhận.
- Giữ quyền dùng ô nghề thứ ba của Famed sau khi kết nối lại.
- Dọn đề nghị dịch vụ cũ khi đổi nghề.
- Kiểm tra đổi nghề trong Microshop trước khi trừ credits.
- Nâng kỹ năng đến đúng cấp tối đa của nghề đã chọn.
- Nạp tên nghề và điểm xin việc theo ID cơ sở dữ liệu, bỏ qua bản ghi sai mà không xóa, giữ bản ghi nền khi thu hồi tài nguyên.
- Nhận diện điểm xin việc dưới các vùng chồng nhau, giới hạn biểu tượng bản đồ theo virtual world và interior đã cấu hình.
- Kiểm tra lại quyền và lựa chọn chỉnh sửa, phân trang đầy đủ các ô điểm nghề và chỉ escape tên nghề khi tạo SQL.
- Sửa hiển thị kỹ năng Arms Dealer, Shipment Contractor và Drug Smuggler, gồm cấp năm khi kỹ năng buôn lậu vượt 884 điểm.
- Bổ sung nghề săn kho báu, thu gom rác và câu cá độc lập vào trợ giúp nghề nghiệp.

#### Hệ thống nghề thu gom rác

- Ngăn timer chất rác chồng nhau làm bỏ qua điểm thu gom, hủy chất rác khi rời xe được giao.
- Yêu cầu đúng người lái xe được giao tại điểm thu gom và bãi rác.
- Cho phép sử dụng đủ chín tuyến thu gom rác hiện có.
- Dọn chuyến khi hủy, nghỉ việc, chết, mất kết nối hoặc xe hồi sinh, không ảnh hưởng trạng thái khóa điều khiển và checkpoint khác.
- Ngăn tràn số khi trả tiền và cộng kỹ năng.

#### Hệ thống nghề câu cá

- Đưa đầy đủ loài đã mở khóa vào lượt câu.
- Áp dụng giới hạn túi cá 1.000 lb mà không cắt bớt khối lượng cá bắt được.
- Ngăn tràn kỹ năng khi nhân đôi kinh nghiệm và áp dụng tăng kỹ năng VIP vào đúng trường Fishing đang dùng.
- Cho phép câu và bán đúng thời điểm hết chờ.
- Giới hạn câu và bán cá cho người chơi đủ điều kiện trong thế giới thông thường.
- Từ chối bán cá khi giá trị tính toán hoặc tiền mặt người chơi vượt giới hạn.
- Giữ checkpoint không liên quan, chỉ dọn checkpoint chợ cá do hệ thống tạo khi đến nơi, bán cá hoặc chết.
- Hiển thị đúng khối lượng cá hiện tại khi khám người chơi.

#### Hệ thống nghề giao pizza

- Khớp điểm giao với interior và virtual world bên ngoài nhà, hỗ trợ cả ô nhà số không.
- Dùng bán kính nhận hàng năm mét tại cả hai Pizza Stack, yêu cầu người nhận đang lái xe.
- Thông báo khi không có điểm giao phù hợp, hủy chuyến khi nhà đã chọn thay đổi hoặc không còn hợp lệ.
- Kiểm tra lại điều kiện nghề và giới hạn tiền mặt trước khi trả thưởng.
- Giữ checkpoint không liên quan khi dọn chuyến giao pizza.

#### Hệ thống nghề vệ sĩ

- Kiểm tra lại danh tính, nghề, trạng thái người bán cùng khoảng cách, virtual world và interior trước khi hoàn tất đề nghị bảo vệ.
- Cho phép trả tiền áo giáp khi vừa đủ tiền, từ chối khi tiền người nhận vượt giới hạn.
- Dọn đầy đủ đề nghị sau khi chấp nhận, hủy hoặc người bán mất kết nối.
- Chặn khám người khi đang xem TV hoặc theo dõi người khác.
- Sửa trợ giúp nghề vệ sĩ theo đúng thời gian chờ đề nghị mười giây.

#### Hệ thống nghề buôn vũ khí

- Khớp danh sách MP5 với điều kiện kỹ năng thực tế.
- Ngăn đề nghị vũ khí cận chiến nhận kinh nghiệm sót từ súng.
- Kiểm tra lại điều kiện người bán, vật liệu, hạn chế người nhận cùng khoảng cách, interior và virtual world trước khi chế tạo.
- Chặn giao vũ khí chế tạo trong sự kiện và trận quyền anh.
- Tiêu thụ đề nghị một lần trước khi cấp vũ khí và kinh nghiệm, dọn đầy đủ khi hủy hoặc người bán mất kết nối.
- Ngăn tràn kỹ năng nghề buôn vũ khí.

#### Hệ thống nghề luật sư

- Khôi phục đọc tham số `/accept lawyer [player]`, kiểm tra lại danh tính, điều kiện và khoảng cách luật sư trước khi thanh toán.
- Cho phép trả phí bào chữa khi vừa đủ tiền, từ chối khi tiền người nhận vượt giới hạn.
- Ngăn thả tù từ xa và luật sư bỏ qua án phạt quản trị.
- Áp dụng miễn phê duyệt luật sư ở cấp kỹ năng năm với 400 điểm.
- Giữ thông báo tăng cấp khi kinh nghiệm nhân đôi vượt ngưỡng kỹ năng.
- Dọn trạng thái trực luật sư sau khi mất kết nối hoặc nghỉ nghề.
- Dọn thông tin bào chữa và kháng cáo đang chờ khi luật sư mất kết nối.
- Kết thúc đại diện kháng cáo khi vụ án đóng hoặc phiên xử mới bắt đầu.
- Chỉ thông báo một lần cho hệ thống tư pháp khi bị cáo chấp nhận kháng cáo.

#### Hệ thống nghề quyền anh

- Cho hai võ sĩ bắt đầu sau cùng một lượt đếm ngược, chỉ ghi thắng, thua và thưởng kỹ năng một lần.
- Kiểm tra lại lời thách đấu, ngắt trận an toàn khi mất kết nối, chết hoặc trạng thái người tham gia thay đổi.
- Đưa võ sĩ về phòng tập nơi bắt đầu trận, khôi phục máu dựa trên giá trị thực tế sau trận.
- Sửa ghi nhận trận thua của nhà vô địch sau các trận bảo vệ danh hiệu.
- Áp dụng đúng giá kiểu chiến đấu VIP đã hiển thị, cho phép thanh toán vừa đủ và chọn kiểu thường miễn phí.
- Kiểm tra lại vị trí tập, giới hạn menu và ID doanh nghiệp trước khi thu phí hoặc ghép võ sĩ đang chờ.

#### Hệ thống nghề săn kho báu

- Cho phép nhận thưởng khi mới vào nghề và khi kỹ năng vượt 9999, bao gồm đầy đủ vật phẩm cùng bậc hiếm ở kỹ năng 150 và 600.
- Áp dụng thời gian chờ máy dò sau khi tìm thành công, giới hạn tìm kiếm và bán hàng trong đúng virtual world và interior.
- Giữ checkpoint không liên quan khi quét tìm kho báu.
- Sửa tra cứu túi đồ bán và trừ rương đã lưu, từ chối tràn giá trị vật phẩm hoặc tiền mặt.
- Ràng buộc nạp túi đồ theo phiên kết nối, chặn thay đổi khi chưa nạp xong và mở rộng bộ đệm lưu đủ số lượng nguyên.

#### Hệ thống nghề vận chuyển

- Ràng buộc timer bốc hàng và cướp hàng với xe cùng phiên kết nối ban đầu.
- Khôi phục đơn doanh nghiệp đang chờ khi hủy chuyến hoặc mất xe, cập nhật lựa chọn khi tài xế khác đã nhận đơn.
- Chuyển quyền rơ-moóc xăng khi bị cướp, đặt lại cảnh báo tách rơ-moóc sau khi nối lại.
- Giới hạn và phân trang danh sách đơn hàng.
- Yêu cầu đúng điểm giao được phân công, tính tiền quãng đường giao hàng doanh nghiệp theo đích thực tế.
- Chỉ cho chọn một phần thưởng vũ khí hợp lệ mỗi chuyến hoàn tất, bỏ thưởng tổ chức khi thiếu điểm bến cảng.

#### Hệ thống nghề thợ máy

- Theo dõi sửa xe ở mọi cấp kỹ năng, hủy khi phiên kết nối hoặc xe không còn hợp lệ.
- Ràng buộc đề nghị dịch vụ với xe ban đầu, ngăn hoàn tất sửa xe mở điều khiển cho người đang bị khống chế.
- Kiểm tra lại lốp trước khi sửa có thu phí, cho phép thanh toán khi vừa đủ tiền.
- Từ chối bơm cho bình đầy, báo đúng lượng nhiên liệu thực sự bổ sung khi gần đầy.
- Khôi phục trạng thái động cơ xe đạp sau sửa chữa.
- Kiểm tra tương thích xe trước khi lắp nâng cấp thợ máy.

#### Hệ thống nghề chế tạo

- Sửa đặt tủ đồ với ô nhà trống, ghi đúng tọa độ nhà trong nhật ký.
- Hủy timer sơ cứu khi hủy thao tác, chết hoặc mất kết nối, cho phép hồi máu đến đầy.
- Dừng camera khi hết pin, dọn ID xe RC sau khi xe bị hủy.
- Giữ vị trí trở về của người chơi khi lưu trong lúc sử dụng camera từ xa.
- Kiểm tra mục tiêu dò thiết bị nghe lén, yêu cầu đúng khoảng cách, interior và virtual world khi chế tạo hoặc dò thiết bị.

#### Hệ thống nhà và giao dịch tài sản

- Sửa đọc số tiền tùy chọn của `/hedit` và `/shophouse`.
- Ghi ID nhà trong nhật ký đổi giá.
- Ngăn bán nhà ghi đè ô nhà đã có của người mua, lưu thanh toán nhà hoặc xe nguyên tử cùng chuyển quyền sở hữu.
- Sửa truy cập chỉ số mục tiêu sai khi hủy hợp đồng.
- Sửa nhận lặp lời mời tổ chức bằng slot người chơi số không.

#### Hệ thống lối ra vào tài sản

- Kiểm tra loại vùng, ID tài sản và dung lượng danh sách vùng, giữ thứ tự ưu tiên lối vào khi vùng chồng nhau.
- Giới hạn lối vào doanh nghiệp, gara theo virtual world và interior, chặn đi vào khi chưa cấu hình tọa độ nội thất.
- Giữ khả năng vào nội thất xe khi chưa chọn tài sản, bảo toàn điều kiện cấp độ vào Casino.
- Loại siêu dữ liệu tài sản khỏi xử lý tương tác cửa nội thất.
- Dọn tài nguyên lối vào nhà, cửa và gara cũ khi xóa, tạo lại hoặc nạp bản ghi trống.
- Tạo lại tài nguyên lối vào nhà sau khi virtual world nội thất thay đổi.

#### Hệ thống doanh nghiệp

- Nạp doanh nghiệp theo ID cố định, từ chối ID sai trước khi chỉnh sửa.
- Khôi phục lợi nhuận doanh nghiệp đã lưu sau khi khởi động lại.
- Lưu khóa doanh nghiệp và thay đổi nội ngoại thất tùy chỉnh.
- Lưu đủ sáu mức lương cấp bậc doanh nghiệp.
- Lưu nhiên liệu và dung tích của từng trụ xăng từ đúng ô tương ứng.
- Giữ đầy đủ mô tả bán doanh nghiệp dài khi lưu.
- Chỉ xác nhận lưu doanh nghiệp sau khi cơ sở dữ liệu phản hồi.
- Giữ phần thập phân tọa độ X của ô xe đại lý số 5.
- Sửa tham số nhật ký xóa trụ xăng.
- Khớp giới hạn vòng lặp danh sách vật phẩm với bảng chuỗi tương ứng.
- Xóa pickup, vùng, trụ xăng và xe liên kết khi xóa doanh nghiệp, ngăn tài nguyên đã xóa xuất hiện lại sau khi nạp.
- Dọn quyền sở hữu và tư cách nhân viên đang trực tuyến hoặc ngoại tuyến của doanh nghiệp đã xóa.
- Chặn xóa doanh nghiệp khi đang bơm xăng, giao hàng hoặc sử dụng nội thất.

#### Hệ thống trợ giúp lệnh

- Giới hạn nạp dữ liệu và danh sách trợ giúp, vô hiệu hóa lựa chọn cũ sau khi nạp lại cơ sở dữ liệu.
- Sửa điều hướng danh mục cùng bộ lọc tổ chức, doanh nghiệp và VIP.

#### Hệ thống nội thất

- Khớp dòng mua với đúng mẫu đã chọn, kiểm tra dữ liệu danh mục và giới hạn nạp 1.000 vật phẩm.
- Giữ danh mục hiện tại cho đến khi làm mới xong, dọn mục cũ khi nạp lại.
- Từ chối báo giá cũ, kiểm tra lại quyền truy cập nhà và điều kiện mua trước khi ghi nhận vị trí đặt cùng thanh toán.
- Dọn tài nguyên tạm khi mua thất bại, dừng gán vật liệu bề mặt nếu không tạo được đối tượng.
- Đọc trực tiếp các trường vị trí từ cache MySQL, chỉ đánh dấu nội thất đã nạp sau khi truy vấn và tạo đối tượng hoàn tất.
- Ngăn khóa vị trí trùng tạo đối tượng lặp mà không chặn các bản ghi hợp lệ phía sau.
- Ngăn nạp trùng đồng thời, từ chối kết quả của nhà hoặc yêu cầu thay thế đã lỗi thời.
- Cho phép thử nạp lại dữ liệu bị treo hoặc nạp dở ở lần vào sau, giữ các đối tượng đã có.

#### Hệ thống tài khoản, bảo trì và bộ đếm thời gian

- Ngăn cập nhật người chơi trùng làm thời gian chờ và thời hạn xuất hiện chạy hai lần mỗi giây.
- Sửa thoát sớm khỏi nhịp cập nhật chung làm bỏ qua người chơi phía sau.
- Giữ đầy đủ văn bản tài khoản đã escape vượt giới hạn lưu cũ.
- Chỉ xác nhận lưu tài khoản sau khi mọi đoạn cập nhật hoàn tất.
- Hủy tắt máy chủ bảo trì nếu lưu thất bại, chờ các lần ghi đang xử lý và lưu người chơi đang kết nối trước khi đóng MySQL.
- Khởi tạo các trường đăng ký bắt buộc để tương thích chế độ SQL nghiêm ngặt.
- Sửa ID tài khoản khi tra PIN cửa hàng.
- Giải phóng yêu cầu thông tin xác thực bị treo sau 30 giây mà không dùng siêu dữ liệu trong chú thích SQL.

#### Hệ thống phá khóa xe

- Hủy phá khóa khi chủ xe hoặc ô xe không còn hợp lệ, sửa định dạng ID tài khoản dạng số trong nhật ký cốp.

#### Cơ sở dữ liệu và định vị IP

- Cho phép chạy lại dữ liệu khởi tạo ô trống sau khi nhập bị gián đoạn trong cùng kết nối SQL.
- Khôi phục tra cứu quốc gia trong thông báo đăng ký bằng dữ liệu IPv4 đã được bổ sung.
- Khởi tạo bảng SQLite còn thiếu cho nhật ký kiểm tra, trò chuyện và kết nối khi khởi động.
- Giữ đầy đủ thông báo nhật ký kiểm tra và trò chuyện dài với tối đa hai lần ghi SQLite trong giao dịch.

#### Hệ thống ngân hàng, tiền mặt và kho cá nhân

- Ghi nhận đồng thời hai bên giao dịch tiền mặt, ngân hàng và ATM.
- Tính cả phí ATM khi kiểm tra số tiền có thể chuyển.
- Chỉ cập nhật số dư ngân hàng trực tuyến sau khi giao dịch được ghi nhận.
- Chỉ áp dụng thời gian chờ trả tiền mặt khi thành công, bỏ lưu tài khoản trùng.
- Ngăn tràn vật liệu, giữ gói hàng và checkpoint khi cập nhật kho thất bại.
- Yêu cầu đúng virtual world và interior giao hàng đã cấu hình trước khi cấp vật liệu hoặc ma túy.

#### Hệ thống cấm nhân sự

- Ghi nhận lịch sử cấm cùng hạn chế tài khoản, thu hồi quyền thống nhất với nhân sự trực tuyến và ngoại tuyến.
- Thực thi hết hạn cấm nhân sự mà không khôi phục cấp bậc cũ.
- Chặn bổ nhiệm nhân sự khi còn bị cấm.
- Giới hạn danh sách cấm nhân sự trực tuyến ở bản ghi còn hiệu lực.
- Ngăn tràn mốc hết hạn, giữ ngày hết hạn thống nhất giữa dữ liệu, thông báo và nhật ký.

#### Hệ thống Microshop và giao hàng cửa hàng tự động

- Ghi nhận đổi số điện thoại cùng trừ credits, từ chối lựa chọn mua cũ, lặp hoặc không hợp lệ.
- Dọn số điện thoại giữ chỗ không còn dùng.
- Lưu đầy đủ giá Microshop và bộ đếm bán hàng khi tuần tự hóa.
- Xóa truy vấn tới `order_delivery_status` không tồn tại.
- Giới hạn thăm dò cửa hàng tự động ở một thao tác đang chờ cho mỗi người chơi.
- Ghi nhận voucher, thay đổi credits và trạng thái đơn hàng trong một thao tác cơ sở dữ liệu.

#### Hệ thống bàn chông

- Chỉ làm thủng lốp có đường đi cắt qua bàn chông đã xoay, áp dụng đúng bit hỏng lốp xe máy và giữ hành vi xe Quad.
- Giới hạn đối tượng bàn chông và kiểm tra người lái trong đúng virtual world, interior triển khai, hỗ trợ tọa độ có trục bằng không.
- Dọn đối tượng, siêu dữ liệu khi xóa hoặc giải tán tổ chức, giải phóng ô khi tạo đối tượng thất bại.

#### Hệ thống điện thoại công cộng

- Xóa ký tự thừa khiến module không biên dịch được.
- Nạp điện thoại theo ID cố định và vị trí thực tế, ánh xạ lựa chọn danh bạ vào ô gọi hợp lệ.
- Giữ nội dung danh bạ khi tra mã vùng, ghép cuộc gọi đến theo đúng số điện thoại và khu vực.
- Theo dõi người dùng tại trạm riêng với người gọi đến, giải phóng quyền sử dụng và điều khiển khi cuộc gọi kết thúc hoặc người chơi rời đi.
- Giữ liên kết cuộc gọi khi gửi SMS, chặn chỉnh sửa hoặc nạp lại trạm đang được sử dụng.
- Giới hạn ghi dữ liệu vào đúng bản ghi điện thoại, chỉ cập nhật đối tượng thế giới sau khi đọc lại dữ liệu đã ghi nhận.

#### Hệ thống Poker

- Xếp hạng năm lá tốt nhất trong bảy lá, so đầy đủ lá phụ và trường hợp hòa.
- Sửa luân phiên người chia bài và blind khi có ghế trống hoặc chỉ còn hai người.
- Kết thúc vòng cược sau đủ hành động bắt buộc, giữ người all-in thiếu blind theo mức đóng thực tế và bỏ yêu cầu theo blind không cần thiết.
- Chia pot chính, pot phụ theo mức đóng góp, phân phần lẻ khi hòa theo thứ tự ghế sau người chia bài.
- Hoàn chip chưa dùng mà không trừ khỏi pot, quyết toán ván đã chia trước khi buộc đóng bàn.

#### Hệ thống hình vẽ băng nhóm

- Nạp hình vẽ băng nhóm bằng kết quả cache R41 theo ID cố định, ánh xạ hộp thoại vào đúng ID cơ sở dữ liệu.
- Dọn tài nguyên cũ khi nạp lại, tuần tự hóa ghi theo từng hình vẽ, chỉ cập nhật đối tượng sau khi đọc lại dữ liệu đã ghi nhận.

#### Thư viện và bản đồ

- Sửa hợp đồng kiểu boolean trong `mSelection.inc`, `callbacks.inc`, truyền đúng kiểu cờ và trạng thái hoạt ảnh tại các nơi gọi của dự án.
- Sửa đích ghi định dạng chuỗi trong `easyDialog.inc`.
- Gán chữ biển nhà tù qua Streamer cho đối tượng động trong `Server.pwn`.
- Truyền khoảng cách bản đồ tàu sân bay vào `streamdistance` thay vì `worldid` trong `Server.pwn`.
- Khắc phục cảnh báo thiếu danh sách mẫu xe khi khởi động cô lập.

### Hiệu năng

#### Hệ thống thùng hàng và cơ sở sản xuất

- Bỏ gắn lại thùng hàng và cập nhật nhãn cơ sở khi trạng thái hiển thị không thay đổi.

#### Hệ thống lãnh thổ

- Chỉ cập nhật lãnh thổ thay đổi trên radar, bỏ ghi lúc khởi động và truy vấn lưu trùng.

#### Hệ thống cổng và cửa động

- Chỉ quét cổng đang hoạt động ở gần, dùng vùng Streamer lân cận cho lệnh khóa và mật khẩu cửa.
- Nạp các bản ghi nền cửa động bằng một truy vấn theo ID SQL.

#### Hệ thống lõi nghề nghiệp

- Xử lý xin việc bằng phím Y qua siêu dữ liệu vùng động thay vì quét mọi ô nghề, xóa mảng xin việc không dùng.
- Tạo SQL điểm nghề bằng một lần định dạng, bỏ lưu dư thừa khi thoát trình chỉnh sửa.

#### Hệ thống nghề câu cá

- Gộp các nhánh câu lặp thành một bảng cá và một luồng xử lý.

#### Hệ thống nghề giao pizza

- Thay chuỗi timer đếm ngược bằng mốc hết hạn kiểm tra trong nhịp cập nhật, chỉ tạo checkpoint giao hàng một lần.
- Bỏ ghi cấu hình máy chủ không liên quan khi trả thưởng giao hàng.

#### Hệ thống nghề vệ sĩ và quyền anh

- Thay chuỗi timer chờ của nghề vệ sĩ bằng so sánh mốc thời gian.
- Cập nhật trận quyền anh duy nhất một lần mỗi nhịp, bỏ bộ nhớ đếm ngược riêng cho từng người chơi.

#### Hệ thống nghề vận chuyển

- Dùng lại một timer đếm ngược bốc hàng, thay timer đếm ngược di chuyển bằng mốc hết hạn.
- Lấy điểm giao từ tuyến được giao thay vì quét mọi điểm đến.

#### Hệ thống nghề thợ máy

- Bỏ quét toàn bộ xe khi đề nghị sửa chữa, dùng lại kết quả tra bộ phận nitro và xe.
- Thay timer kiểm tra lên xe và chờ tự tiếp nhiên liệu bằng callback trạng thái và mốc thời gian.

#### Hệ thống nghề chế tạo

- Bỏ kiểm tra camera RC từng người chơi trong timer cập nhật định kỳ.

#### Hệ thống doanh nghiệp

- Nối trường SQL mà không định dạng lại phần truy vấn đã có, nạp giá vật phẩm một lần mỗi bản ghi.
- Bỏ tạo lại tài nguyên đối với chỉnh sửa không làm thay đổi tài nguyên hiển thị.

#### Hệ thống tài khoản, nhà và dữ liệu dùng chung

- Giảm định dạng lặp và quét chuỗi khi tạo truy vấn lưu tài khoản.
- Nạp nhà trực tiếp từ truy vấn tổng thay vì truy vấn lại từng ô.
- Đóng gói bảng chuỗi tĩnh và giải nén giá trị tại nơi đọc.

#### SQLite và định vị IP

- Dùng lại kết nối GeoIP chỉ đọc và journal nhật ký SQLite, giữ ghi nhận nhật ký đồng bộ.

### Bảo mật

#### Hệ thống bầu cử

- Ràng buộc xác nhận với phiên kết nối và đợt bầu cử ban đầu, kiểm tra lại điều kiện cử tri và giới hạn ứng viên khi bỏ phiếu.
- Khóa chỉnh sửa ứng viên khi bỏ phiếu hoặc đếm phiếu, từ chối tên chèn dòng hộp thoại hoặc mã màu.

#### Hệ thống kéo và tạm giữ xe

- Yêu cầu người lái có quyền và xe mục tiêu không chở người trong cùng virtual world, interior, từ chối thưởng không hợp lệ hoặc tràn số.

#### Hệ thống lương và ngân sách tổ chức

- Kiểm tra lại quyền lãnh đạo và quốc gia khi xác nhận, ràng buộc hộp thoại với tổ chức ban đầu cùng giới hạn cấp bậc, số tiền hợp lệ.

#### Hệ thống giấy phép súng

- Từ chối kết quả cấp phép từ phiên cũ hoặc yêu cầu đã bị thay thế, kiểm tra người nhận trước khi truy cập dữ liệu người chơi.

#### Hệ thống thực thi pháp luật

- Từ chối callback kéo người, vật ngã còng tay, nạp súng điện và hỗ trợ đã cũ sau khi slot được tái sử dụng.
- Kiểm tra chỉ số người chơi, xe, tổ chức, yêu cầu cùng virtual world và interior khi khống chế hoặc tịch thu.

#### Hệ thống cửa động

- Kiểm tra lại danh tính cửa và khoảng cách khi trả lời mật khẩu, từ chối callback sở hữu cũ sau khi phiên kết nối hoặc cửa thay đổi.
- Ẩn mật khẩu khỏi thông tin trạng thái nhân sự và nhật ký kiểm tra.

#### Hệ thống đề nghị dịch vụ và giao dịch tài sản

- Ràng buộc đề nghị đang chờ với phiên kết nối ban đầu, chặn lưu trạng thái cũ khi không xác minh được kết quả bán tài sản.
- Ngăn thanh toán dịch vụ thợ máy làm tràn tiền mặt người nhận.

#### Hệ thống Poker

- Từ chối cược sai lượt hoặc lặp, chặn mua chip và dùng lại ghế khi ván chưa kết thúc.
- Ngăn dọn trạng thái rời bàn có độ trễ ảnh hưởng phiên kết nối hoặc bàn mới.

#### Hệ thống ngân hàng và thanh toán tiền mặt

- Ràng buộc xác nhận thanh toán, chuyển tiền với tài khoản và kết nối đã chọn, ngăn người nhận bị thay thế và giao dịch lặp.
- Từ chối số tiền không hợp lệ hoặc tràn số, kiểm tra khoảng cách, interior và virtual world khi trả tiền mà không cho bỏ qua bằng TV.

#### Hệ thống tài khoản và thông tin xác thực

- Ẩn truy vấn lưu tài khoản, thông tin xác thực, định danh kết nối và tham số đặt lại thông tin xác thực khỏi lỗi và nhật ký.
- Từ chối đăng nhập khi thiếu bản ghi tài khoản hoặc hash không phải bcrypt, không quay về cơ chế cũ.
- Ràng buộc callback xác thực với phiên, tài khoản và yêu cầu ban đầu, từ chối kết quả truy vấn cũ sau khi slot được tái sử dụng.
- Bỏ lưu mật khẩu dạng rõ trong `pLastPass`, ngừng hiển thị lại mật khẩu và PIN sau khi đổi.

#### Hệ thống nhật ký kiểm tra và trò chuyện

- Kiểm tra ID người chơi, giới hạn tên bảng trong danh sách cho phép và escape giá trị SQLite.
- Bỏ xuất toàn bộ truy vấn từ `DBLog` và `ChatDBLog`.

#### Hệ thống nội thất

- Kiểm tra chỉ số nhà, ô đặt nội thất và vật liệu bề mặt trước khi truy cập mảng.

#### Hệ thống giao hàng cửa hàng tự động

- Ngăn giao hàng lặp, từ chối số lượng sai, tràn số hoặc trạng thái phiên, tài khoản không khớp trước khi cấp hàng.

#### Hệ thống điện thoại công cộng và hình vẽ băng nhóm

- Từ chối kết quả ghi điện thoại công cộng và hình vẽ băng nhóm đã cũ bằng phiên bản tài nguyên và danh tính người yêu cầu.
- Kiểm tra ID, văn bản, giới hạn phông chữ của hình vẽ băng nhóm, xác minh chủ sở hữu timer phun và tẩy trước khi thay đổi trạng thái.
