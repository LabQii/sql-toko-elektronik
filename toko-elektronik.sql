CREATE DATABASE db_elektronik;
USE db_elektronik;
-- DROP DATABASE db_elektronik;

CREATE TABLE data_barang (
  id_barang INT(100) PRIMARY KEY AUTO_INCREMENT,
  nama_barang VARCHAR(100) DEFAULT NULL,
  harga_barang INT(100) DEFAULT NULL,
  stok INT(100) DEFAULT NULL,
  total_barang_terjual INT(100) DEFAULT NULL
);

CREATE TABLE data_pembayaran (
  id_transaksi INT(11) PRIMARY KEY AUTO_INCREMENT,
  id_barang INT(100) NOT NULL,
  nama_produk VARCHAR(100) NOT NULL,
  harga_produk INT(20) NOT NULL,
  jumlah_pembelian INT(20) NOT NULL,
  total_harga INT(20) NOT NULL
);

CREATE TABLE `history_delete` (
  id_log INT PRIMARY KEY AUTO_INCREMENT,
  id_barang INT,
  nama_barang VARCHAR(255),
  action VARCHAR(10),
  timestamp TIMESTAMP
);

CREATE TABLE `user_form` (
  `id` INT(11) PRIMARY KEY,
  `name` VARCHAR(255) DEFAULT NULL,
  `email` VARCHAR(255) DEFAULT NULL,
  `password` VARCHAR(255) DEFAULT NULL,
  `user_type` VARCHAR(50) DEFAULT NULL
);

CREATE TABLE history_login (
    id_login INT PRIMARY KEY AUTO_INCREMENT,
    id_admin INT DEFAULT NULL,
    `nama` VARCHAR(255) DEFAULT NULL,
    `email` VARCHAR(255) DEFAULT NULL,
    `timestamp` TIMESTAMP 
);

ALTER TABLE user_form MODIFY COLUMN id INT(11) AUTO_INCREMENT;

ALTER TABLE data_pembayaran 
    ADD CONSTRAINT fk_idbarang 
    FOREIGN KEY (id_barang) REFERENCES data_barang(id_barang) 
    ON UPDATE CASCADE ON DELETE CASCADE;
    
ALTER TABLE history_delete 
    ADD CONSTRAINT fk_historyidbarang 
    FOREIGN KEY (id_barang) REFERENCES data_barang(id_barang) 
    ON UPDATE CASCADE ON DELETE CASCADE;

INSERT INTO `data_barang` (`id_barang`, `nama_barang`, `harga_barang`, `stok`, `total_barang_terjual`) VALUES
(72, 'TV', 5000000, 10, 5),
(73, 'Laptop', 8000000, 15, 8),
(74, 'Smartphone', 3000000, 20, 12),
(75, 'Speaker', 1000000, 12, 6),
(76, 'Kamera', 6000000, 8, 4),
(77, 'Headphone', 500000, 25, 15),
(78, 'Printer', 2000000, 5, 2),
(79, 'Microwave', 1500000, 7, 3),
(80, 'AC', 7000000, 9, 5),
(81, 'Mesin Cuci', 4000000, 11, 7),
(82, 'Kulkas', 5500000, 8, 4),
(83, 'Blender', 500000, 10, 6),
(84, 'Rice Cooker', 300000, 18, 10),
(85, 'Iron', 200000, 14, 8),
(86, 'Vacuum Cleaner', 2500000, 6, 3),
(87, 'Monitor', 1500000, 12, 7),
(88, 'Camera Drone', 9000000, 4, 2),
(89, 'Game Console', 3500000, 15, 9),
(90, 'Wireless Router', 500000, 20, 12),
(91, 'Projector', 3000000, 8, 5);

-- STORE PROCEDURE 
-- 1. Melihat Barang
DELIMITER $$
CREATE PROCEDURE SeeBarang(IN idbarang1 INT)
BEGIN
    SELECT * FROM data_barang WHERE id_barang = idbarang1;
END$$
DELIMITER ;

-- 2. Menamabah Data Barang 
DELIMITER $$
CREATE PROCEDURE InsertDataBarang (IN p_nama VARCHAR(255), IN p_harga DECIMAL(10,2), IN p_stok INT)
BEGIN
    INSERT INTO data_barang (id_barang, nama_barang, harga_barang, stok, total_barang_terjual)
    VALUES (NULL, p_nama, p_harga, p_stok, '');
END$$
DELIMITER ;

-- 3. Mengupdate Data Barang
DELIMITER $$
CREATE PROCEDURE UpdateDataBarang(IN p_stokbarangbaru INT, IN p_totalbarangbaru INT, IN p_idbarang1 INT)
BEGIN
    UPDATE data_barang
    SET stok = p_stokbarangbaru, total_barang_terjual = p_totalbarangbaru
    WHERE id_barang = p_idbarang1;
END$$
DELIMITER ;

-- 4. Menambah Data Pembayaran
DELIMITER $$
CREATE PROCEDURE InsertDataPembayaran(IN p_idbarang1 INT, IN p_namabarang1 VARCHAR(255), IN p_hargabarang1 INT, IN p_beli1 INT, IN p_totalhargabaru INT)
BEGIN
    INSERT INTO data_pembayaran (id_transaksi, idbarang, nama_produk, harga_produk, jumlah_pembelian, total_harga)
    VALUES (NULL, p_idbarang1, p_namabarang1, p_hargabarang1, p_beli1, p_totalhargabaru);
END$$
DELIMITER ;

-- 5. Hapus Data Barang
DELIMITER $$
CREATE PROCEDURE DeleteDataBarang()
BEGIN	
    DELETE FROM data_barang;
END $$
DELIMITER ;

-- 6. Menambah Stok Selusin pada setiap stok (menggonakan looping)
DELIMITER //
CREATE PROCEDURE DuabelasStokBarang()
BEGIN
  DECLARE counter INT DEFAULT 1;
  
  WHILE counter <= 12 DO
    UPDATE data_barang SET stok = stok + 1;
    SET counter = counter + 1;
  END WHILE;
END //
DELIMITER ;

-- 7. Menambah Data User
DELIMITER //
CREATE PROCEDURE InsertDataUserForm(IN name VARCHAR(255), IN email VARCHAR(255), IN password VARCHAR(255), IN user_type VARCHAR(255))
BEGIN
    INSERT INTO user_form (name, email, password, user_type)
    VALUES (p_name, p_email, p_password, p_user_type);
END //
DELIMITER ;


-- TRIGGERS
-- 1. Trigger Delete Pembayaran
--  Ini berarti setiap kali data barang dihapus, data pembayaran yang terkait dengan barang tersebut juga akan dihapus dari tabel data_pembayaran. 
DELIMITER $$
CREATE TRIGGER `trg_delete_pembayaran` BEFORE DELETE ON `data_barang` FOR EACH ROW BEGIN
	DELETE FROM data_pembayaran WHERE idbarang = OLD.id_barang;
END$$
DELIMITER ;

-- 2. Trigger Delete Data Barang
DELIMITER $$
CREATE TRIGGER trg_delete_data_barang
AFTER DELETE ON data_barang
FOR EACH ROW
BEGIN
    INSERT INTO `history_delete` (id_barang, nama_barang, action, timestamp)
    VALUES (OLD.id_barang, OLD.nama_barang, 'DELETE', NOW());
END$$
DELIMITER ;

-- 3. Trigger Update Data Barang
-- Dalam trigger ini, setiap kali terjadi operasi pembaruan (UPDATE) pada tabel data_barang, trigger akan memeriksa apakah nilai kolom stok pada baris sebelum (OLD) dan setelah (NEW) pembaruan berbeda. Jika ada perubahan pada kolom stok, maka baris lama (OLD) akan dimasukkan ke dalam tabel history_delete dengan tindakan 'UPDATE'. Pastikan tabel history_delete telah dibuat sebelum Anda menggunakan trigger ini. 
DELIMITER $$
CREATE TRIGGER trg_update_data_barang
AFTER UPDATE ON data_barang
FOR EACH ROW
BEGIN
    IF OLD.stok <> NEW.stok THEN
        INSERT INTO history_delete (id_barang, nama_barang, action, timestamp)
        VALUES (OLD.id_barang, OLD.nama_barang, 'UPDATE', NOW());
    END IF;
END$$
DELIMITER ;

-- 4. Trigger Tambah Data Barang
-- Dalam trigger ini, setiap kali terjadi operasi penambahan data (INSERT) pada tabel data_barang, trigger akan memasukkan baris baru (NEW) ke dalam tabel history_delete dengan tindakan 'INSERT'. Pastikan tabel history_delete telah dibuat sebelum Anda menggunakan trigger ini. 
DELIMITER $$
CREATE TRIGGER trg_insert_data_barang
AFTER INSERT ON data_barang
FOR EACH ROW
BEGIN
    INSERT INTO `history_delete` (id_barang, nama_barang, action, timestamp)
    VALUES (NEW.id_barang, NEW.nama_barang, 'INSERT', NOW());
END$$
DELIMITER ;

-- 5. Trigger Tambah History Login 
DELIMITER $$
CREATE TRIGGER trg_insert_history_login
AFTER INSERT ON user_form
FOR EACH ROW
BEGIN
    INSERT INTO history_login (id_admin, nama, email, timestamp)
    VALUES (NEW.id, NEW.`name`, NEW.email, NOW());
END$$
DELIMITER ;

-- VIEWS
-- 1. Viem Pembayaran
CREATE VIEW view_pembayaran AS
SELECT dp.id_transaksi, dp.nama_produk, dp.harga_produk, dp.jumlah_pembelian, dp.total_harga
FROM data_pembayaran dp;

-- 2. View Data Barang
CREATE VIEW view_data_barang AS
SELECT *
FROM data_barang
WHERE id_barang = id_barang;

-- 3. View Keranjang
CREATE VIEW view_keranjang AS
SELECT id_barang, nama_barang, harga_barang, stok, total_barang_terjual
FROM data_barang
ORDER BY id_barang ASC;

-- 4. History Delete
CREATE VIEW view_history_delete AS
SELECT * FROM `history_delete`;

-- 5. History Login
CREATE VIEW view_history_login AS
SELECT * FROM `history_login`;

-- 6. View User Formulir
CREATE VIEW view_user_form AS
SELECT * FROM user_form
WHERE email = email AND `password` = `password`;


