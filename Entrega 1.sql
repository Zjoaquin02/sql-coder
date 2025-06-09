use prueba;

-- Base de datos para un laboratorio bioquimico

-- Tabla de Clientes
CREATE TABLE Clientes (
    id_cliente INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100),
    apellido VARCHAR(100),
    dni VARCHAR(20),
    telefono VARCHAR(20),
    email VARCHAR(100)
);

-- Tabla de Médicos
CREATE TABLE Medicos (
    id_medico INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100),
    apellido VARCHAR(100),
    matricula VARCHAR(50),
    especialidad VARCHAR(100),
    telefono VARCHAR(20)
);

-- Tabla de Tipos de Análisis
CREATE TABLE TiposAnalisis (
    id_analisis INT PRIMARY KEY AUTO_INCREMENT,
    nombre_analisis VARCHAR(100),
    descripcion TEXT,
    precio DECIMAL(10, 2)
);


-- Estados turnos
INSERT INTO EstadosTurno (id_estado, nombre_estado) VALUES
(1, 'Pendiente'),
(2, 'Realizado'),
(3, 'Cancelado'),
(4, 'Reprogramado');



-- Tabla turnos
CREATE TABLE Turnos (
    id_turno INT PRIMARY KEY AUTO_INCREMENT,
    id_cliente INT,
    id_medico INT,
    id_analisis INT,
    fecha_turno DATE,
    hora_turno TIME,
    observaciones TEXT,
    id_estado INT,
    FOREIGN KEY (id_cliente) REFERENCES Clientes(id_cliente),
    FOREIGN KEY (id_medico) REFERENCES Medicos(id_medico),
    FOREIGN KEY (id_analisis) REFERENCES TiposAnalisis(id_analisis),
    FOREIGN KEY (id_estado) REFERENCES EstadosTurno(id_estado)
);


-- Tabla de Estados de Turno
CREATE TABLE EstadosTurno (
    id_estado INT PRIMARY KEY AUTO_INCREMENT,
    nombre_estado VARCHAR(50) -- Ej: Pendiente, Realizado, Cancelado, Reprogramado
);


-- Tabla logs trigger
CREATE TABLE LogEstadosRealizados (
    id_log INT PRIMARY KEY AUTO_INCREMENT,
    id_turno INT,
    id_cliente INT,
    id_medico INT,
    fecha_registro DATETIME
);


-- Carga de clientes
INSERT INTO Clientes (nombre, apellido, dni, telefono, email) VALUES
('Juan', 'Pérez', '30123456', '1134567890', 'juan.perez@gmail.com'),
('María', 'Gómez', '29234567', '1145678901', 'maria.gomez@hotmail.com'),
('Carlos', 'Fernández', '28111222', '1156789012', 'carlos.fernandez@yahoo.com'),
('Ana', 'Rodríguez', '27123456', '1167890123', 'ana.rodriguez@gmail.com'),
('Lucía', 'Martínez', '30111111', '1178901234', 'lucia.martinez@hotmail.com'),
('Diego', 'Sánchez', '31234567', '1189012345', 'diego.sanchez@gmail.com'),
('Sofía', 'López', '32222222', '1190123456', 'sofia.lopez@yahoo.com'),
('Martín', 'García', '33123456', '1132109876', 'martin.garcia@gmail.com'),
('Florencia', 'Díaz', '34123456', '1143209876', 'flor.diaz@hotmail.com'),
('Federico', 'Torres', '35123456', '1154309876', 'fede.torres@gmail.com');


-- Carga de medicos
INSERT INTO Medicos (nombre, apellido, matricula, especialidad, telefono) VALUES
('Laura', 'Medina', 'MP12345', 'Clínica Médica', '1123456789'),
('Javier', 'Ruiz', 'MP23456', 'Pediatría', '1134567890'),
('Silvia', 'Alonso', 'MP34567', 'Medicina General', '1145678901'),
('Andrés', 'Cabrera', 'MP45678', 'Endocrinología', '1156789012'),
('Paula', 'Herrera', 'MP56789', 'Infectología', '1167890123');


-- Carga de analisis
INSERT INTO TiposAnalisis (nombre_analisis, descripcion, precio) VALUES
('Hemograma Completo', 'Estudio de células sanguíneas.', 1500.00),
('Glucemia', 'Medición de glucosa en sangre.', 800.00),
('Colesterol Total', 'Medición del colesterol en sangre.', 950.00),
('Perfil Hepático', 'Evaluación de enzimas y función del hígado.', 1800.00),
('Uroanálisis', 'Análisis completo de orina.', 1200.00);


-- Carga de turnos
INSERT INTO Turnos (id_cliente, id_medico, id_analisis, fecha_turno, hora_turno, observaciones, id_estado) VALUES
(1, 1, 1, '2025-04-10', '08:30:00', 'Ayuno de 8 horas.', 1),
(2, 2, 2, '2025-04-10', '09:00:00', '', 1),
(3, 3, 3, '2025-04-11', '10:15:00', 'Paciente diabético.', 1),
(4, 1, 4, '2025-04-11', '11:00:00', '', 1),
(5, 4, 5, '2025-04-12', '08:45:00', '', 2),
(6, 5, 1, '2025-04-12', '09:30:00', '', 3),
(7, 2, 2, '2025-04-13', '10:00:00', 'Reprogramado por médico.', 4),
(8, 3, 3, '2025-04-13', '11:30:00', '', 1),
(9, 1, 4, '2025-04-14', '08:00:00', '', 1),
(10, 5, 5, '2025-04-14', '09:15:00', '', 2);

--  -----------------------------VIEWS----------------------- --
-- View: Cantidad de analisis por dia
CREATE VIEW VistaAnalisisPorDia AS
SELECT
    fecha_turno,
    COUNT(*) AS cantidad_analisis
FROM
    Turnos
GROUP BY
    fecha_turno
ORDER BY
    fecha_turno;

SELECT * FROM VistaAnalisisPorDia; -- Muesta los analisis que se hicieron en cada dia

CREATE VIEW VistaRecaudacionTotal AS
SELECT
    SUM(ta.precio) AS total_recaudado
FROM Turnos t
JOIN TiposAnalisis ta ON t.id_analisis = ta.id_analisis
JOIN EstadosTurno e ON t.id_estado = e.id_estado
WHERE e.nombre_estado = 'Realizado';


SELECT * FROM VistaRecaudacionTotal; -- Muestra el total de recaudacion del laboratorio

-- -------------Trigger----------------------- --
DELIMITER $$

CREATE TRIGGER trg_log_estado_realizado
AFTER UPDATE ON Turnos
FOR EACH ROW
BEGIN
    IF OLD.id_estado <> NEW.id_estado AND NEW.id_estado = 2 THEN
        INSERT INTO LogEstadosRealizados (id_turno, id_cliente, id_medico, fecha_registro)
        VALUES (NEW.id_turno, NEW.id_cliente, NEW.id_medico, NOW());
    END IF;
END $$

DELIMITER ;

SELECT * FROM LogEstadosRealizados ORDER BY fecha_registro DESC; -- Compara el estado anterior con el nuevo si es 2 guarda un log con id y fecha en el que se realizo el evento

-- -------------Funcion----------------------- --
DELIMITER $$

CREATE FUNCTION contar_turnos_cliente(cliente_id INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE cantidad INT;
    SELECT COUNT(*) INTO cantidad
    FROM Turnos
    WHERE id_cliente = cliente_id;
    RETURN cantidad;
END $$

DELIMITER ;

SELECT id_cliente, contar_turnos_cliente(id_cliente) AS cantidad_turnos FROM Clientes;

-- ----------------Procedimiento almacenado----------------------- --
DELIMITER $$

CREATE PROCEDURE registrar_turno_simple (
    IN p_id_cliente INT,
    IN p_id_medico INT,
    IN p_id_analisis INT,
    IN p_fecha DATE,
    IN p_hora TIME,
    IN p_obs TEXT,
    IN p_estado INT
)
BEGIN
    INSERT INTO Turnos (
        id_cliente, id_medico, id_analisis,
        fecha_turno, hora_turno, observaciones, id_estado
    ) VALUES (
        p_id_cliente, p_id_medico, p_id_analisis,
        p_fecha, p_hora, p_obs, p_estado
    );
END $$

DELIMITER ;
-- Ejemplo -- 
CALL registrar_turno_simple(3, 2, 4, '2025-05-23', '12:00:00', 'Chequeo', 1);

-- --------------------Usuario y permisos------------------------- --
CREATE USER 'usuario_lectura'@'localhost' IDENTIFIED BY 'joaquin';
GRANT SELECT ON prueba.* TO 'usuario_lectura'@'localhost';

-- --------------------Entrega final------------------------- --
-- Vista con los analisis mas solicitados --
CREATE VIEW VistaTopAnalisis AS
SELECT
    ta.nombre_analisis,
    COUNT(*) AS cantidad_solicitudes
FROM Turnos t
JOIN TiposAnalisis ta ON t.id_analisis = ta.id_analisis
GROUP BY ta.id_analisis
ORDER BY cantidad_solicitudes DESC;

-- Vista de medico con mas turnos asignados --
CREATE VIEW VistaTopMedico AS
SELECT
    CONCAT(m.nombre, ' ', m.apellido) AS medico,
    COUNT(*) AS cantidad_turnos
FROM Turnos t
JOIN Medicos m ON t.id_medico = m.id_medico
GROUP BY m.id_medico
ORDER BY cantidad_turnos DESC
LIMIT 1;

-- Turnos programados en el dia --
CREATE VIEW VistaTurnosHoy AS
SELECT * FROM Turnos
WHERE fecha_turno = CURDATE();

-- Proximo turno --
CREATE VIEW VistaProximoTurno AS
SELECT * FROM Turnos
WHERE fecha_turno >= CURDATE()
ORDER BY fecha_turno, hora_turno
LIMIT 1;


