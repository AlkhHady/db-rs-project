DROP DATABASE IF EXISTS rumah_sakit;
CREATE DATABASE rumah_sakit;
USE rumah_sakit;

CREATE TABLE dokter (
    id_dokter VARCHAR(4) PRIMARY KEY,
    nama_dokter VARCHAR(100) NOT NULL,
    spesialis_dokter VARCHAR(50) NOT NULL,
    telepon_dokter VARCHAR(15) UNIQUE,
    alamat_dokter VARCHAR(200)
);

CREATE TABLE pasien (
    id_pasien VARCHAR(4) PRIMARY KEY,
    nama_pasien VARCHAR(100) NOT NULL,
    lahir_pasien DATE NOT NULL,
    kelamin_pasien VARCHAR(10) NOT NULL,
    telepon_pasien VARCHAR(15) UNIQUE,
    alamat_pasien VARCHAR(200)
);

CREATE TABLE pemeriksaan (
    id_pemeriksaan VARCHAR(5) PRIMARY KEY,
    id_dokter VARCHAR(4) NOT NULL,
    id_pasien VARCHAR(4) NOT NULL,
    tanggal_pemerikssan DATE NOT NULL,
    keluhan VARCHAR(200) NOT NULL,
    diagnosis VARCHAR(100) NOT NULL,
    CONSTRAINT fk_pemeriksaan_dokter
        FOREIGN KEY (id_dokter) REFERENCES dokter (id_dokter)
        ON DELETE RESTRICT,
    CONSTRAINT fk_pemeriksaan_pasien
        FOREIGN KEY (id_pasien) REFERENCES pasien (id_pasien)
        ON DELETE CASCADE
);

CREATE TABLE obat (
    id_obat VARCHAR(4) PRIMARY KEY,
    id_pemeriksaan VARCHAR(5) UNIQUE,
    nama_obat VARCHAR(100) NOT NULL,
    harga INT NOT NULL DEFAULT 0,
    CONSTRAINT fk_obat_pemeriksaan
        FOREIGN KEY (id_pemeriksaan) REFERENCES pemeriksaan (id_pemeriksaan)
        ON DELETE CASCADE
);

CREATE TABLE pembayaran (
    id_pembayaran VARCHAR(4) PRIMARY KEY,
    id_pemeriksaan VARCHAR(5) UNIQUE,
    id_obat VARCHAR(4) NOT NULL,
    tagihan INT NOT NULL DEFAULT 0,
    status_bayar ENUM('Lunas','Belum Lunas') NOT NULL DEFAULT 'Belum Lunas',
    CONSTRAINT fk_pembayaran_pemeriksaan
        FOREIGN KEY (id_pemeriksaan) REFERENCES pemeriksaan (id_pemeriksaan)
        ON DELETE CASCADE,
    CONSTRAINT fk_pembayaran_obat
        FOREIGN KEY (id_obat) REFERENCES obat (id_obat)
        ON DELETE RESTRICT
);

INSERT INTO dokter (id_dokter, nama_dokter, spesialis_dokter, telepon_dokter, alamat_dokter) VALUES
('D001', 'Dr. Budi Santoso, Sp.A', 'Anak', '081234567890', 'Jl. Sudirman No. 12, Padang'),
('D002', 'Dr. Siti Rahma, Sp.PD', 'Penyakit Dalam', '081345678901', 'Jl. Khatib Sulaiman No. 45, Padang'),
('D003', 'Dr. Ahmad Fauzi, Sp.B', 'Bedah', '081456789012', 'Jl. Ahmad Yani No. 8, Padang');

INSERT INTO pasien (id_pasien, nama_pasien, lahir_pasien, kelamin_pasien, telepon_pasien, alamat_pasien) VALUES
('P001', 'Rian Hidayat', '1995-05-12', 'Laki-laki', '082111222333', 'Jl. Veteran No. 10, Padang'),
('P002', 'Dewi Lestari', '1998-08-20', 'Perempuan', '082222333444', 'Jl. Proklamasi No. 15, Padang'),
('P003', 'Andi Pratama', '1988-02-14', 'Laki-laki', '082333444555', 'Jl. Belibis No. 22, Padang');

INSERT INTO pemeriksaan (id_pemeriksaan, id_dokter, id_pasien, tanggal_pemerikssan, keluhan, diagnosis) VALUES
('RM001', 'D001', 'P001', '2026-10-01', 'Demam tinggi dan batuk beruntun', 'Infeksi Saluran Pernapasan Akut (ISPA)'),
('RM002', 'D002', 'P002', '2026-10-02', 'Nyeri lambung dan mual', 'Gastritis Akut'),
('RM003', 'D003', 'P003', '2026-10-03', 'Luka robek pada tangan akibat kecelakaan', 'Vulnera Lacerata');

INSERT INTO obat (id_obat, id_pemeriksaan, nama_obat, harga) VALUES
('OB01', 'RM001', 'Paracetamol Syrup & Amoxicillin', 75000),
('OB02', 'RM002', 'Omeprazole & Antasida Doen', 45000),
('OB03', 'RM003', 'NaCl 0.9% & Jarum Jahit Bedah', 120000);

INSERT INTO pembayaran (id_pembayaran, id_pemeriksaan, id_obat, tagihan, status_bayar) VALUES
('BY01', 'RM001', 'OB01', 175000, 'Lunas'),
('BY02', 'RM002', 'OB02', 95000, 'Belum Lunas'),
('BY03', 'RM003', 'OB03', 220000, 'Belum Lunas');

UPDATE pembayaran SET status_bayar = 'Lunas', tagihan = 100000 WHERE id_pembayaran = 'BY02';
UPDATE pasien SET telepon_pasien = '082299887766' WHERE id_pasien = 'P002';
DELETE FROM pemeriksaan WHERE id_pemeriksaan = 'RM003';

SELECT * FROM dokter;
SELECT * FROM pasien WHERE kelamin_pasien = 'Laki-laki';
SELECT p.id_pemeriksaan, d.nama_dokter, ps.nama_pasien, p.tanggal_pemerikssan, p.diagnosis FROM pemeriksaan p JOIN dokter d ON p.id_dokter = d.id_dokter JOIN pasien ps ON p.id_pasien = ps.id_pasien;
SELECT o.id_obat, o.nama_obat, o.harga, p.keluhan FROM obat o JOIN pemeriksaan p ON o.id_pemeriksaan = p.id_pemeriksaan;
SELECT * FROM pembayaran WHERE status_bayar = 'Belum Lunas';
SELECT SUM(tagihan) AS total_pendapatan FROM pembayaran;
SELECT AVG(harga) AS rata_rata_harga_obat FROM obat;
SELECT kelamin_pasien, COUNT(*) AS jumlah_pasien FROM pasien GROUP BY kelamin_pasien;
SELECT * FROM pembayaran WHERE status_bayar = 'Lunas' ORDER BY tagihan DESC;
SELECT * FROM pasien WHERE nama_pasien LIKE '%Rian%';

CREATE USER 'resepsionis'@'localhost' IDENTIFIED BY 'PasswordResepsionis123';
CREATE USER 'kasir'@'localhost' IDENTIFIED BY 'PasswordKasir123';

GRANT SELECT, INSERT ON rumah_sakit.pasien TO 'resepsionis'@'localhost';
GRANT SELECT, INSERT ON rumah_sakit.pemeriksaan TO 'resepsionis'@'localhost';

GRANT SELECT, INSERT, UPDATE ON rumah_sakit.pembayaran TO 'kasir'@'localhost';
GRANT SELECT ON rumah_sakit.obat TO 'kasir'@'localhost';

FLUSH PRIVILEGES;

REVOKE INSERT ON rumah_sakit.pasien FROM 'resepsionis'@'localhost';
REVOKE ALL PRIVILEGES ON rumah_sakit.obat FROM 'kasir'@'localhost';

FLUSH PRIVILEGES;

DELETE FROM pasien WHERE id_pasien = 'P001';
