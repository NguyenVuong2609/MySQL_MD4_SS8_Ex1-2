CREATE DATABASE TicketFilm;
USE TicketFilm;

-- Tạo bảng
CREATE TABLE tblPhim (
PhimID int primary key,
ten_phim varchar(30),
loai_phim varchar(25),
thoi_gian int
);

CREATE TABLE tblPhong (
PhongID int primary key,
ten_phong varchar(20),
trang_thai tinyint
);

CREATE TABLE tblGhe (
GheID int primary key,
PhongID int,
So_ghe varchar(10),
foreign key (PhongID) references tblPhong(PhongID)
);

CREATE TABLE tblVe (
PhimID int,
GheID int,
Ngay_chieu datetime,
trang_thai varchar(20),
foreign key (PhimID) references tblPhim(PhimID),
foreign key (GheID) references tblGhe(GheID)
);

-- Thêm dữ liệu
insert into tblPhim values 
(1, "Em bé Hà Nội", "Tâm lý",90),
(2, "Nhiệm vụ bất khả thi", "Hành Động",100),
(3, "Dị Nhân", "Viễn Tưởng",90),
(4, "Cuốn theo chiều gió", "Tình Cảm",120);

insert into tblPhong values 
(1, "Phòng chiếu 1", 1),
(2, "Phòng chiếu 2", 1),
(3, "Phòng chiếu 3", 0);

insert into tblGhe values
(1,1,"A3"),
(2,1,"B5"),
(3,2,"A7"),
(4,2,"D1"),
(5,3,"T2");

insert into tblVe values
(1,1,"2008-10-20", "Đã bán"),
(1,3,"2008-11-20", "Đã bán"),
(1,4,"2008-12-23", "Đã bán"),
(2,1,"2009-02-14", "Đã bán"),
(3,1,"2009-02-14", "Đã bán"),
(2,5,"2009-03-08", "Chưa bán"),
(2,3,"2009-03-08", "Chưa bán");

-- Hiển thị danh sách các phim (chú ý: danh sách phải được sắp xếp theo trường Thoi_gian)
select * from tblPhim order by thoi_gian;

-- Hiển thị Ten_phim có thời gian chiếu dài nhất
select ten_phim
from tblphim 
where thoi_gian = (select max(thoi_gian) from tblphim);

-- Hiển thị Ten_Phim có thời gian chiếu ngắn nhất
select ten_phim
from tblphim 
where thoi_gian = (select min(thoi_gian) from tblphim);

-- Hiển thị danh sách So_Ghe mà bắt đầu bằng chữ ‘A’
select row_number() over (order by GheID) as 'STT', So_ghe
from tblghe
where So_ghe like "A%";

-- Sửa cột Trang_thai của bảng tblPhong sang kiểu nvarchar(25)
alter table tblphong modify column trang_thai varchar(25);

-- Xóa tất cả các khóa ngoại trong các bảng trên
alter table tblghe drop foreign key tblghe_ibfk_1;
alter table tblve drop foreign key tblve_ibfk_1;
alter table tblve drop foreign key tblve_ibfk_2;

-- Cập nhật giá trị cột Trang_thai của bảng tblPhong theo các luật sau:			
-- Nếu Trang_thai=0 thì gán Trang_thai=’Đang sửa’
-- Nếu Trang_thai=1 thì gán Trang_thai=’Đang sử dụng’
-- Nếu Trang_thai=null thì gán Trang_thai=’Unknow’
DELIMITER //
CREATE PROCEDURE Update_then_show_status()
BEGIN
	update tblphong set trang_thai = if(trang_thai=0,"Đang sửa",if(Trang_thai=1,"Đang sử dụng","Unknow"));
    select * from tblphong; 
END //

-- Hiển thị danh sách tên phim mà  có độ dài >15 và < 25 ký tự 	
select ten_phim 
from tblphim
where length(ten_phim) between 15 and 25;

-- Hiển thị Ten_Phong và Trang_Thai trong bảng tblPhong  trong 1 cột với tiêu đề ‘Trạng thái phòng chiếu’
select concat_WS("-",ten_phong, trang_thai) as `Trạng thái phòng chiếu`
from tblphong;

-- Tạo view có tên tblRank với các cột sau: STT(thứ hạng sắp xếp theo Ten_Phim), TenPhim, Thoi_gian
CREATE VIEW tblRank AS
select row_number() over (order by ten_phim) as 'STT', ten_phim, thoi_gian
FROM tblphim;
select * from tblRank;

-- Trong bảng tblPhim :
-- Thêm trường Mo_ta kiểu nvarchar(max)		
alter table tblphim add column Mo_ta varchar(255);
-- Cập nhật trường Mo_ta: thêm chuỗi “Đây là bộ phim thể loại  ” + nội dung trường LoaiPhim
update tblphim set Mo_ta = concat("Đây là bộ phim thể loại ", loai_phim);										
-- Hiển thị bảng tblPhim sau khi cập nhật
select * from tblPhim;		
-- Cập nhật trường Mo_ta: thay chuỗi “bộ phim” thành chuỗi “film” (Dùng replace)
update tblphim set Mo_ta = replace(Mo_ta, "bộ phim", "film");
-- Hiển thị bảng tblPhim sau khi cập nhật	
select * from tblPhim;		

-- Xóa dữ liệu ở bảng tblGhe
delete from tblghe;

-- Hiển thị ngày giờ hiện chiếu và ngày giờ chiếu cộng thêm 5000 phút trong bảng tblVe
select (day(addtime(Ngay_chieu, "83:00:00"))) as `Ngay_chieu`, (addtime(time(Ngay_chieu), "11:20:00")) as `Gio_chieu`
from tblve;