@extends('layouts.tempNav')
@section('container')
{{-- <h1>{{ $user[$data]->id }}</h1> --}}
<h3 class="mb-4"><i class="fa-solid fa-user-group"></i> Daftar Pengguna</h3>
<div class="row">
    <div class="col">
        <a href="#"><button type="button" class="btn btn-outline-warning" ><i class="fa-solid fa-plus"></i> Tambah Pengguna</button></a>
    </div>
    <div class="col-3">
        <form action="/listUser">
            <div class="input-group mb-3">
                <input type="text" class="form-control" placeholder="Cari Pengguna..." name="search">
                <button class="btn btn-outline-secondary" type="submit">Cari</button>
            </div>
        </form>
    </div>
</div>
<hr>
<div class="container">
    <table class="table text-center">
        <thead>
            <th scope="col">ID</th>
            <th scope="col">Nama</th>
            <th scope="col">Aksi</th>
        </thead>
        <tbody class="table-group-divider">
            @foreach ($user as $user)  
            {{-- $user->id --}}
            <tr>
                <td>{{ $user->id }}</td>
                <td>{{ $user->name }}</td>
                <td>
                    <div class="btn-group btn-group-sm" role="group" aria-label="Small button group">
                        <a href="listUser/{{ $user->id }}" data-bs-toggle="modal" data-bs-target="#infoAccount">
                            <button type="button" class="btn btn-outline-info" data-bs-toggle="tooltip" data-bs-placement="top" data-bs-custom-class="custom-tooltip" data-bs-title="Tampilkan Detail Informasi">
                                <i class="fa-solid fa-info"></i>
                            </button>
                        </a>
                        <a href="#"><button type="button" class="btn btn-outline-primary" data-bs-toggle="tooltip" data-bs-placement="top" data-bs-custom-class="custom-tooltip" data-bs-title="Tampilkan Absensi Sholat"><i class="fa-solid fa-list-check"></i></button></a>
                        <a href="#"><button type="button" class="btn btn-outline-secondary" data-bs-toggle="tooltip" data-bs-placement="top" data-bs-custom-class="custom-tooltip" data-bs-title="Reset Paswword"><i class="fa-solid fa-rotate-right"></i></button></a>
                        <a href="#"><button type="button" class="btn btn-outline-danger" data-bs-toggle="tooltip" data-bs-placement="top" data-bs-custom-class="custom-tooltip" data-bs-title="Hapus Pengguna"><i class="fa-solid fa-trash"></i></button></a>
                    </div>
                </td>
            </tr>
            @endforeach
        </tbody>
    </table> 
</div> 
<div class="modal fade" id="infoAccount" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-labelledby="infoAccountLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content">
            <div class="modal-header">
                <h1 class="modal-title fs-5" id="infoAccountLabel">Detail Pengguna</h1>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
            <div class="row">
                <div class="col-4">
                    <img src="https://github.com/mdo.png" alt="Foto Profil" width="150">
                </div>
                <div class="col">
                    <table class="table">
                        <thead>
                        </thead>
                        <tbody>
                          <tr>
                            <th scope="row">ID</th>
                            <td>{{ $user[$data]->id }}</td>
                          </tr>
                          <tr>
                            <th scope="row">Nama</th>
                            <td>{{ $user[$data]->name }}</td>
                          </tr>
                          <tr>
                            <th scope="row">Email</th>
                            <td>{{ $user[$data]->email }}</td>
                          </tr>
                          <tr>
                            <th scope="row">No HP</th>
                            <td>{{ $user[$data]->no_hp }}</td>
                          </tr>
                        </tbody>
                      </table>
                </div>
            </div>
            </div>
            <div class="modal-footer">
            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
            </div>
        </div>
    </div>
</div>
@endsection