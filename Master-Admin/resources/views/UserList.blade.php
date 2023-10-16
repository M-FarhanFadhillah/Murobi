@extends('layouts.tempNav')
@section('container')
{{-- <h1>{{ $user[$data]->id }}</h1> --}}
<h3 class="mb-4"><i class="fa-solid fa-user-group"></i> Daftar Pengguna</h3>
<div class="row">
    <div class="col">
        <a href="#"><button type="button" class="btn btn-outline-warning" data-bs-toggle="modal" data-bs-target="#addUser"><i class="fa-solid fa-plus"></i> Tambah Pengguna</button></a>
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
                        <a href="" data-bs-toggle="modal" data-bs-target="#infoAccount-{{ $user->id }}">
                            <button type="button" class="btn btn-outline-info" data-bs-toggle="tooltip" data-bs-placement="top" data-bs-custom-class="custom-tooltip" data-bs-title="Tampilkan Detail Informasi">
                                <i class="fa-solid fa-info"></i>
                            </button>
                        </a>
                        <a href="" data-bs-toggle="modal" data-bs-target="#infoSholat-{{ $user->id }}"><button type="button" class="btn btn-outline-primary" data-bs-toggle="tooltip" data-bs-placement="top" data-bs-custom-class="custom-tooltip" data-bs-title="Tampilkan Absensi Sholat"><i class="fa-solid fa-list-check"></i></button></a>
                        <a href="#"><button type="button" class="btn btn-outline-secondary" data-bs-toggle="tooltip" data-bs-placement="top" data-bs-custom-class="custom-tooltip" data-bs-title="Reset Paswword"><i class="fa-solid fa-rotate-right"></i></button></a>
                        <form action="/listUser" method="POST">
                            @method('delete')
                            @csrf
                            <button onclick="return confirm('Anda yakin ingin menghapus data?')" type="button" class="btn btn-outline-danger" data-bs-toggle="tooltip" data-bs-placement="top" data-bs-custom-class="custom-tooltip" data-bs-title="Hapus Pengguna"><i class="fa-solid fa-trash"></i></button>
                        </form>
                    </div>
                </td>
            </tr>
            @endforeach
        </tbody>
    </table> 
</div>
{{-- Modal Tambah Pengguna --}}
<div class="modal fade" id="addUser" tabindex="-1" aria-labelledby="addUserLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable">
      <div class="modal-content">
        <div class="modal-header">
          <h1 class="modal-title fs-5" id="addUserLabel">Daftarkan Pengguna Baru</h1>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
        </div>
        <div class="modal-body">
            <form>
                <div class="mb-3">
                  <label for="InputEmail1" class="form-label">Email address</label>
                  <input type="email" class="form-control" id="InputEmail1" aria-describedby="emailHelp">
                </div>
                <div class="mb-3">
                  <label for="InputName1" class="form-label">Nama</label>
                  <input type="text" class="form-control" id="InputName1" aria-describedby="nameHelp">
                </div>
                <div class="mb-3">
                  <label for="InputHP1" class="form-label">No. HP</label>
                  <input type="tel" class="form-control" id="InputHP1" aria-describedby="HPHelp">
                </div>
                <div class="mb-3">
                    <label for="formFile" class="form-label">Foto Profil</label>
                    <input class="form-control" type="file" id="formFile">
                  </div>
                <div class="mb-3">
                  <label for="InputPassword1" class="form-label">Password</label>
                  <input type="password" class="form-control" id="InputPassword1">
                </div>
                <button type="submit" class="btn btn-primary">Submit</button>
              </form>
        </div>
      </div>
    </div>
  </div>
{{-- Modal Details --}}
@foreach ($data as $item)
<div class="modal fade" id="infoSholat-{{ $item->id }}" tabindex="-1" aria-labelledby="infoSholatLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h1 class="modal-title fs-5" id="infoSholatLabel">Absensi Sholat {{ $item->name }}</h1>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <table class="table text-center">
                    <thead>
                      <tr>
                        <th scope="col">Subuh</th>
                        <th scope="col">Dzuhur</th>
                        <th scope="col">Ashar</th>
                        <th scope="col">Mahgrib</th>
                        <th scope="col">Isya</th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr>
                        <td>Masjid</td>
                        <td>Masjid</td>
                        <td>Masjid</td>
                        <td>Masjid</td>
                        <td>Masjid</td>
                      </tr>
                      <tr>
                        <td>Berjamaah</td>
                        <td>Berjamaah</td>
                        <td>Berjamaah</td>
                        <td>Berjamaah</td>
                        <td>Berjamaah</td>
                      </tr>
                    </tbody>
                  </table>
            </div>
        </div>
    </div>
</div>
</div>
@endforeach 
{{-- Modal Absensi Sholat --}}
@foreach ($data as $item)
<div class="modal fade" id="infoAccount-{{ $item->id }}" tabindex="-1" aria-labelledby="infoAccountLabel" aria-hidden="true">
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
                            <td>{{ $item->id }}</td>
                          </tr>
                          <tr>
                              <th scope="row">Nama</th>
                              <td>{{ $item->name }}</td>
                            </tr>
                            <tr>
                                <th scope="row">Email</th>
                                <td>{{ $item->email }}</td>
                            </tr>
                            <tr>
                                <th scope="row">No HP</th>
                                <td>{{ $item->no_hp }}</td>
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
@endforeach 
@endsection