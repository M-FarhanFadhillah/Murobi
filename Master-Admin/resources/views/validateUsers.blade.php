@extends('layouts.tempNav')
@section('container')
<div class="row">
    <div class="col-6 .col-sm-4"><h3><i class="fa-solid fa-user-group"></i> Daftar Pengguna</h3></div>
</div>
<hr>
<div class="container">
    <table class="table text-center">
        <thead>
            <th scope="col">No</th>
            <th scope="col">Email</th>
            <th scope="col">Nama</th>
            <th scope="col">Aksi</th>
        </thead>
        <tbody class="table-group-divider">
            <tr>
                <td>1</td>
                <td>syahril799@gmail.com</td>
                <td>Syahril Fajri Pratama</td>
                <td>
                    <div class="btn-group btn-group-sm" role="group" aria-label="Small button group">
                        <a href="#"><button type="button" class="btn btn-outline-success" data-bs-toggle="tooltip" data-bs-placement="top" data-bs-custom-class="custom-tooltip" data-bs-title="Konfirmasi Pendaftar"><i class="fa-solid fa-check"></i></button></a>
                        <a href="#"><button type="button" class="btn btn-outline-danger" data-bs-toggle="tooltip" data-bs-placement="top" data-bs-custom-class="custom-tooltip" data-bs-title="Tolak Pendaftar"><i class="fa-solid fa-x"></i></button></a>
                    </div>
                </td>
            </tr>
        </tbody>
    </table> 
</div> 
@endsection