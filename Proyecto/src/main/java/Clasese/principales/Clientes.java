package Clasese.principales;

import java.time.LocalDate;

public class Clientes {
    
    int id_cliente;
    long cedula;
    String nombre;
    String apellido;
    long telefono;
    LocalDate fechaingreso;
    String direccion;
    
    public Clientes(){
    }

    public Clientes(int id_cliente, long cedula, String nombre, String apellido, long telefono, LocalDate fechaingreso, String direccion) {
        this.id_cliente = id_cliente;
        this.cedula = cedula;
        this.nombre = nombre;
        this.apellido = apellido;
        this.telefono = telefono;
        this.fechaingreso = fechaingreso;
        this.direccion = direccion;
    }

    public int getId_cliente() {
        return id_cliente;
    }

    public void setId_cliente(int id_cliente) {
        this.id_cliente = id_cliente;
    }

    public long getCedula() {
        return cedula;
    }

    public void setCedula(long cedula) {
        this.cedula = cedula;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getApellido() {
        return apellido;
    }

    public void setApellido(String apellido) {
        this.apellido = apellido;
    }

    public long getTelefono() {
        return telefono;
    }

    public void setTelefono(long telefono) {
        this.telefono = telefono;
    }

    public LocalDate getFechaingreso() {
        return fechaingreso;
    }

    public void setFechaingreso(LocalDate fechaingreso) {
        this.fechaingreso = fechaingreso;
    }

    public String getDireccion() {
        return direccion;
    }

    public void setDireccion(String direccion) {
        this.direccion = direccion;
    }
    
    
    
}
