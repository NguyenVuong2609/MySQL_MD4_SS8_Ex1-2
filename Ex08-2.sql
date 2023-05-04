create database rikkei_academy_ex8_2;
use rikkei_academy_ex8_2;

create table Class (
ClassID int primary key auto_increment,
ClassName varchar(255) not null,
StartDate datetime not null,
status bit
);

create table Student (
StudentID int primary key,
StudentName varchar(30) not null,
address varchar(50),
phone varchar(20),
status bit,
ClassID int not null
);

create table Subject (
SubId int primary key auto_increment,
SubName varchar(30) not null,
Credit tinyint default(1) check(Credit >= 1),
Status bit default(1)
);

create table Mark (
MarkID int primary key auto_increment,
SubId int not null,
StudentID int not null,
Mark float default(0) check(Mark between 0 and 100),
ExamTimes tinyint default(1),
unique (SubId, StudentID)
);

-- Thêm ràng buộc khóa ngoại trên cột ClassID của  bảng Student, tham chiếu đến cột ClassID trên bảng Class.
alter table Student add foreign key (ClassID) references Class(ClassID);

-- Thêm ràng buộc cho cột StartDate của  bảng Class là ngày hiện hành.
alter table Class modify StartDate datetime default(curdate());

-- Thêm ràng buộc mặc định cho cột Status của bảng Student là 1
alter table Student modify Status bit default(1);

-- Thêm ràng buộc khóa ngoại cho bảng Mark trên cột SubID trên bảng Mark tham chiếu đến cột SubID trên bảng Subject ,StudentID tren bảng Mark tham chiếu đến cột StudentID của bảng Student.
alter table Mark add foreign key (SubID) references Subject(SubID);
alter table Mark add foreign key (StudentID) references Student(StudentID);

-- Thêm dữ liệu vào các bảng
insert into class (className, startDate, status) values
("A1","2008-12-20",1),
("A2","2008-12-22",1),
("B3",curdate(),0);
insert into student values
(1,"Hung","Ha noi","0912113113",1,1),
(2,"Hoa","Hai phong",null,1,1),
(3,"Manh","HCM", "0123123123",0,2);
insert into subject (subName,credit,status) values
("CF",5,1),
("C",6,1),
("HDJ",5,1),
("RDBMS",10,1);
insert into mark (subID,studentID,mark,examTimes) values
(1,1,8,1),
(1,2,10,2),
(3,1,12,1);


-- Thay đổi mã lớp(ClassID) của sinh viên có tên ‘Hung’ là 2
update student set ClassID = 2 where StudentName like "Hung";   

-- Cập nhật cột phone trên bảng sinh viên là ‘No phone’ cho những sinh viên chưa có số điện thoại
update student set phone = "No phone" where phone is null;

-- Nếu trạng thái của lớp (Status) là 0 thì thêm từ ‘New’ vào trước tên lớp
update class set classname = concat("New ", classname) where status = 0;

-- Nếu trạng thái của status trên bảng Class là 1 và tên lớp bắt đầu là ‘New’ thì thay thế ‘New’ bằng ‘old’
update class set classname = replace(classname,"New","Old") where (status = 1 and ClassName like "New%");

-- Nếu lớp học chưa có sinh viên thì thay thế trạng thái là 0 (status=0)
update class set status = 0 
where not exists (select 1 from student s where (s.classID = class.classID));

-- Cập nhật trạng thái của môn học (bảng subject) là 0 nếu môn học đó chưa có sinh viên dự thi
update subject set status = 0
where not exists (select 1 from mark m where (m.subid = subject.subid));

-- Hiển thị tất cả các sinh viên có tên bắt đầu bảng ký tự ‘h’
select * from student where studentname like "h%";

-- Hiển thị các thông tin lớp học có thời gian bắt đầu vào tháng 12
select * from class where month(startdate) = 12;

-- Hiển thị giá trị lớn nhất của credit trong bảng subject
select max(credit) from subject;

-- Hiển thị tất cả các thông tin môn học (bảng subject) có credit lớn nhất
select *
from subject
where credit = (select max(credit) from subject);

-- Hiển thị tất cả các thông tin môn học có credit trong khoảng từ 3-5
select *
from subject
where credit between 3 and 5;

-- Hiển thị các thông tin bao gồm: classid, className, studentname, Address từ hai bảng Class, student
select c.classId, c.classname, s.studentname, s.address
from student s 
join class c on c.classid = s.classid;

-- Hiển thị các thông tin môn học chưa có sinh viên dự thi
select * from subject where not exists (select 1 from mark m where (m.subid = subject.subid));

-- Hiển thị các thông tin môn học có điểm thi lớn nhất.
select *
from subject s 
where subid = (select subid from mark where mark = (select max(mark) from mark));

-- Hiển thị các thông tin sinh viên và điểm trung bình tương ứng
select s.studentID, s.studentname, s.address, s.phone, s.status, avg(m.mark)
from student s
join mark m on m.studentId = s.studentid
group by s.studentid;

-- Hiển thị các thông tin sinh viên và điểm trung bình của mỗi sinh viên, xếp hạng theo thứ tự điểm giảm dần
select s.studentID, s.studentname, s.address, s.phone, s.status, rank() over (order by avg(m.mark) DESC) as `Rank`
from student s
join mark m on m.studentId = s.studentid
group by s.studentid;

-- Hiển thị các thông tin sinh viên và điểm trung bình, chỉ đưa ra các sinh viên có điểm trung bình lớn hơn 10
select s.studentID, s.studentname, s.address, s.phone, s.status, avg(m.mark)
from student s
join mark m on m.studentId = s.studentid
group by s.studentid
having avg(m.mark) > 10;

-- Hiển thị các thông tin: StudentName, SubName, Mark. Dữ liệu sắp xếp theo điểm thi (mark) giảm dần. nếu trùng sắp theo tên tăng dần
select s.studentname, sb.subname, m.mark
from mark m
join student s on s.studentid = m.studentid
join subject sb on sb.subid = m.subid
order by m.mark DESC, s.studentname ASC;

-- Xóa tất cả các lớp có trạng thái là 0
delete from class where status = 0;

-- Xóa tất cả các môn học chưa có sinh viên dự thi
delete from subject where not exists (select 1 from mark m where (m.subid = subject.subid));