@extends('layouts.tempNav')
@section('container')
<div class="row">
    <div class="col"><h3><i class="fa-solid fa-address-card"></i> Validasi Pendaftaran</h3></div>
    <div class="col-3">
        <form action="/validateRegist">
            <div class="input-group mb-3">
                <input type="text" class="form-control" placeholder="Cari Calon Pengguna..." name="search">
                <button class="btn btn-outline-secondary" type="submit">Cari</button>
            </div>
        </form>
    </div>
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
            @foreach ($user as $user)  
            <tr>
                <td>1</td>
                <td>{{ $user->email }}</td>
                <td>{{ $user->name }}</td>
                <td>
                    <div class="btn-group btn-group-sm" role="group" aria-label="Small button group">
                        <a href="#"><button type="button" class="btn btn-outline-success" data-bs-toggle="tooltip" data-bs-placement="top" data-bs-custom-class="custom-tooltip" data-bs-title="Konfirmasi Pendaftar"><i class="fa-solid fa-check"></i></button></a>
                        <a href="#"><button type="button" class="btn btn-outline-danger" data-bs-toggle="tooltip" data-bs-placement="top" data-bs-custom-class="custom-tooltip" data-bs-title="Tolak Pendaftar"><i class="fa-solid fa-x"></i></button></a>
                    </div>
                </td>
            </tr>
            @endforeach
        </tbody>
    </table> 
</div> 
@endsection