-- Usar la base de datos master como contexto inicial
USE master;
GO

-- Crear base de datos si no existe
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'RegistroPersona')
BEGIN
    CREATE DATABASE RegistroPersona;
    PRINT 'Base de datos RegistroPersona creada exitosamente.';
END
ELSE
BEGIN
    PRINT 'La base de datos RegistroPersona ya existe.';
END
GO

-- Cambiar al contexto de la nueva base de datos
USE RegistroPersona;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    -- Crear tabla Región
    IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Region' AND type = 'U')
    BEGIN
        CREATE TABLE Region (
            Id INT IDENTITY(1,1) PRIMARY KEY,
            Nombre NVARCHAR(100) NOT NULL
        );
        PRINT 'Tabla Region creada exitosamente.';
    END

    -- Crear tabla TipoPersona
    IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'TipoPersona' AND type = 'U')
    BEGIN
        CREATE TABLE TipoPersona (
            Id INT IDENTITY(1,1) PRIMARY KEY,
            Nombre NVARCHAR(100) NOT NULL UNIQUE
        );
        PRINT 'Tabla TipoPersona creada exitosamente.';
    END

    -- Insertar datos iniciales en TipoPersona
    IF NOT EXISTS (SELECT 1 FROM TipoPersona WHERE Nombre = 'Agente')
    BEGIN
        INSERT INTO TipoPersona (Nombre) VALUES ('Agente');
    END

    IF NOT EXISTS (SELECT 1 FROM TipoPersona WHERE Nombre = 'Civil')
    BEGIN
        INSERT INTO TipoPersona (Nombre) VALUES ('Civil');
    END
        IF NOT EXISTS (SELECT 1 FROM TipoPersona WHERE Nombre = 'Administrador')
    BEGIN
        INSERT INTO TipoPersona (Nombre) VALUES ('Administrador');
    END
    PRINT 'Datos iniciales insertados en TipoPersona.';

    -- Crear tabla Persona si no existe
    IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Persona' AND type = 'U')
    BEGIN
        CREATE TABLE Persona (
        Id VARCHAR(36) PRIMARY KEY DEFAULT NEWID(),
            [Primer Nombre] NVARCHAR(50) NOT NULL,
            [Segundo Nombre] NVARCHAR(50) NULL,
            [Primer Apellido] NVARCHAR(50) NOT NULL,
            [Segundo Apellido] NVARCHAR(50) NULL,
            [Fecha de nacimiento] DATE NOT NULL,
            [Fecha de residencia] DATE NOT NULL,
            [Tipo de sangre] NVARCHAR(3) NULL,
            RegionId INT NULL,
            TipoPersonaId INT NULL,
            Genero NVARCHAR(20) NULL,
            Foto VARBINARY(MAX) NULL,
            Estado NVARCHAR(20)  NULL ,

            CONSTRAINT FK_Persona_Region FOREIGN KEY (RegionId) 
                REFERENCES Region(Id)
                ON DELETE SET NULL
                ON UPDATE CASCADE,

            CONSTRAINT FK_Persona_TipoPersona FOREIGN KEY (TipoPersonaId)
                REFERENCES TipoPersona(Id)
                ON DELETE SET NULL
                ON UPDATE CASCADE,

            CONSTRAINT CHK_TipoSangre CHECK (
                [Tipo de sangre] IN ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-')
            ),
            CONSTRAINT CHK_Estado CHECK (
                Estado IN ('Confirmado', 'Pendiente', 'Vencido')
            )
        );
        PRINT 'Tabla Persona creada exitosamente.';
    END
    ELSE
    BEGIN
        -- Agregar columna TipoPersonaId si no existe
        IF NOT EXISTS (
            SELECT * FROM sys.columns 
            WHERE Name = N'TipoPersonaId' AND Object_ID = Object_ID(N'Persona')
        )
        BEGIN
            ALTER TABLE Persona ADD TipoPersonaId INT NULL;
            ALTER TABLE Persona ADD CONSTRAINT FK_Persona_TipoPersona 
                FOREIGN KEY (TipoPersonaId) REFERENCES TipoPersona(Id)
                ON DELETE SET NULL ON UPDATE CASCADE;
            PRINT 'Columna TipoPersonaId agregada a la tabla Persona.';
        END
    END

    -- Crear índice si no existe
    IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Persona_Nombre' AND object_id = OBJECT_ID('Persona'))
    BEGIN
        CREATE INDEX IX_Persona_Nombre ON Persona([Primer Nombre], [Primer Apellido]);
        PRINT 'Índice IX_Persona_Nombre creado exitosamente.';
    END

    -- Insertar regiones si están vacías
    IF NOT EXISTS (SELECT 1 FROM Region)
    BEGIN
        INSERT INTO Region (Nombre) VALUES 
        ('Norte'), ('Sur'), ('Este'), ('Oeste'), ('Centro');
        PRINT 'Datos iniciales insertados en la tabla Region.';
    END

    COMMIT TRANSACTION;
    PRINT 'Transacción completada exitosamente.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT 'Se produjo un error: ' + ERROR_MESSAGE();
END CATCH;
